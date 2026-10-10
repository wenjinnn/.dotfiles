#!/usr/bin/env python3
"""Restore a paper-reel BLE device to a configured operating mode."""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
import queue
import time
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

from bleak import BleakClient, BleakScanner  # type: ignore[import-not-found]

try:
    import gattlib  # type: ignore[import-not-found]
except ImportError:
    gattlib = None

LOG = logging.getLogger("reef-roll-filter-ble-gateway")

DEVICE_NAME = "Paper_reel_REDACTED"
WRITE_UUID = "0000ffe9-0000-1000-8000-00805f9b34fb"
NOTIFY_UUID = "0000ffe4-0000-1000-8000-00805f9b34fb"
CCCD_UUID = "00002902-0000-1000-8000-00805f9b34fb"
STATE_QUERY_PAYLOAD = bytes.fromhex("47 54 00 02 01 31")

MODES = {
    "auto": 0x01,
    "timer": 0x02,
    "eco": 0x03,
    "clean": 0x04,
}


def mode_payload(mode: str) -> bytes:
    """Return the observed FFE9 Write Without Response payload for ``mode``."""
    try:
        value = MODES[mode]
    except KeyError as error:
        raise ValueError(f"unsupported mode: {mode}") from error
    return bytes.fromhex("50 54 00 06 05 F8 01") + bytes((value, 0x00, 0x00))


def expected_notifications(mode: str) -> tuple[bytes, bytes]:
    """Return the short echo and long state notifications for ``mode``."""
    value = MODES[mode]
    short = bytes.fromhex("52 50 00 06 05 F8 01") + bytes((value, 0x00, 0x00))
    long = bytes.fromhex("52 54 00 0D 0C 31") + bytes(
        (value, 0x00, 0x00, 0x64, 0x01, 0x00, 0x00, 0x05, 0x01, 0x01, 0x01)
    )
    return short, long


def hex_bytes(value: bytes) -> str:
    return value.hex(" ").upper()


def notification_mode(data: bytes) -> str | None:
    value = bytes(data)
    for mode in MODES:
        short, long = expected_notifications(mode)
        if value == short:
            return mode
        if (
            len(value) >= 7
            and value[0] == 0x52
            and value[1] in (0x50, 0x54)
            and value[2:6] == long[2:6]
            and value[6] == long[6]
        ):
            return mode
    return None


def is_long_state_notification(data: bytes, mode: str) -> bool:
    expected = expected_notifications(mode)[1]
    value = bytes(data)
    return (
        len(value) >= 7
        and value[0] == 0x52
        and value[1] in (0x50, 0x54)
        and value[2:6] == expected[2:6]
        and value[6] == expected[6]
    )


def monitor_transition(
    state: str,
    device_found: bool,
    absent_count: int,
    absent_scans: int,
) -> tuple[str, int, bool]:
    """Advance the outage state machine and report whether recovery was detected."""
    if device_found:
        return "present", 0, state == "absent"
    if state != "present":
        return state, absent_count, False
    next_absent_count = absent_count + 1
    if next_absent_count >= absent_scans:
        return "absent", next_absent_count, False
    return "present", next_absent_count, False


def load_monitor_state(path: str | None) -> str:
    if not path:
        return "unknown"
    try:
        state = json.loads(Path(path).read_text()).get("state")
    except (OSError, ValueError, AttributeError):
        return "unknown"
    return state if state in {"unknown", "present", "absent"} else "unknown"


def save_monitor_state(path: str | None, state: str) -> bool:
    if not path:
        return True
    target = Path(path)
    temporary = target.with_suffix(".tmp")
    try:
        target.parent.mkdir(parents=True, exist_ok=True)
        temporary.write_text(json.dumps({"state": state}) + "\n")
        os.replace(temporary, target)
        return True
    except OSError:
        LOG.exception("could not persist monitor state to %s", target)
        return False


def recovery_window_open(
    recovery_days: tuple[int, ...],
    window_start: str,
    window_end: str,
    now: datetime | None = None,
) -> bool:
    current = now or datetime.now()
    if current.weekday() not in recovery_days:
        return False
    start = datetime.strptime(window_start, "%H:%M").time()
    end = datetime.strptime(window_end, "%H:%M").time()
    return start <= current.time() <= end


def identity_confident(device: Any, settings: Settings) -> bool:
    return bool(
        settings.address
        and str(getattr(device, "address", "")).lower() == settings.address.lower()
    )


def _full_uuid(uuid: str) -> str:
    normalized = uuid.lower()
    if len(normalized) == 6 and normalized.startswith("0x"):
        normalized = normalized[2:]
    if len(normalized) == 4:
        return f"0000{normalized}-0000-1000-8000-00805f9b34fb"
    return normalized


def find_characteristic(services: Any, uuid: str) -> Any:
    wanted = _full_uuid(uuid)
    for service in services:
        for characteristic in service.characteristics:
            if _full_uuid(characteristic.uuid) == wanted:
                return characteristic
    raise RuntimeError(f"BLE characteristic not found: {uuid}")


def _advertisement_name(device: Any, advertisement: Any | None) -> str | None:
    names = [getattr(device, "name", None)]
    if advertisement is not None:
        names.append(getattr(advertisement, "local_name", None))
    return next((name for name in names if name), None)


def matches_device(
    device: Any,
    advertisement: Any | None,
    address: str,
    name: str,
) -> bool:
    wanted_address = address.strip().lower()
    wanted_name = name.strip()
    device_address = str(getattr(device, "address", "")).lower()
    device_name = _advertisement_name(device, advertisement)
    if wanted_address and device_address == wanted_address:
        return True
    return bool(wanted_name and device_name == wanted_name)


async def _stop_scanner(scanner: Any, timeout: float) -> None:
    stop = getattr(scanner, "stop", None)
    if stop is None:
        return
    try:
        await asyncio.wait_for(stop(), timeout)
    except Exception as error:
        LOG.warning("BLE scanner cleanup failed: %s", error)


async def discover_target(settings: Settings) -> Any | None:
    discovered: dict[str, tuple[Any, Any]] = {}
    activity = 0

    def remember_device(device: Any, advertisement: Any) -> None:
        nonlocal activity
        activity += 1
        address = str(getattr(device, "address", "")).lower()
        if address:
            discovered[address] = (device, advertisement)

    scanner = BleakScanner(detection_callback=remember_device)
    cleaned_up = False
    try:
        await asyncio.wait_for(scanner.start(), settings.scan_timeout)
        LOG.info("BLE scanner started")
        await asyncio.sleep(settings.scan_timeout)
        if activity == 0:
            LOG.warning("BLE scan produced no advertisements; preserving monitor state")
            raise TransientBleError
        for device, advertisement in discovered.values():
            if matches_device(device, advertisement, settings.address, settings.name):
                LOG.info(
                    "found %s (%s)",
                    _advertisement_name(device, advertisement) or "unnamed device",
                    device.address,
                )
                return device
        return None
    except asyncio.CancelledError:
        await asyncio.shield(_stop_scanner(scanner, settings.scan_timeout))
        cleaned_up = True
        raise
    except TransientBleError:
        raise
    except Exception as error:
        LOG.warning("BLE scan failed; retrying at the next check: %s", error)
        raise TransientBleError from error
    finally:
        if not cleaned_up:
            await _stop_scanner(scanner, settings.scan_timeout)


class TransientBleError(RuntimeError):
    """A BLE transaction failed before its result could be trusted."""


@dataclass(frozen=True)
class Settings:
    mode: str
    address: str
    name: str
    scan_timeout: float
    scan_interval: float
    absent_scans: int
    recovery_delay: float
    recovery_days: tuple[int, ...]
    recovery_window_start: str
    recovery_window_end: str
    connect_timeout: float
    notify_timeout: float
    mode_check_interval: float
    scheduled_check_time: str
    state_file: str | None


async def _wait_for_notification(
    notifications: asyncio.Queue[bytes],
    mode: str | None,
    timeout: float,
    long_state: bool = False,
) -> bytes | None:
    deadline = asyncio.get_running_loop().time() + timeout
    while True:
        remaining = deadline - asyncio.get_running_loop().time()
        if remaining <= 0:
            return None
        try:
            value = await asyncio.wait_for(notifications.get(), remaining)
        except asyncio.TimeoutError:
            return None
        LOG.info("FFE4 notify: %s", hex_bytes(value))
        detected_mode = notification_mode(value)
        if (
            detected_mode is not None
            and (mode is None or detected_mode == mode)
            and (not long_state or is_long_state_notification(value, detected_mode))
        ):
            return value


async def _read_state(
    client: Any,
    write_characteristic: Any,
    notifications: asyncio.Queue[bytes],
    settings: Settings,
) -> bytes | None:
    _drain_notifications(notifications)
    await client.write_gatt_char(
        write_characteristic, STATE_QUERY_PAYLOAD, response=False
    )
    state = await _wait_for_notification(
        notifications,
        None,
        settings.notify_timeout,
    )
    if state is not None:
        LOG.info("FFE4 notification state: %s", hex_bytes(state))
    return state


async def _write_mode(
    client: Any,
    write_characteristic: Any,
    notifications: asyncio.Queue[bytes],
    settings: Settings,
) -> bool:
    payload = mode_payload(settings.mode)
    LOG.info("writing %s mode to FFE9: %s", settings.mode, hex_bytes(payload))
    await client.write_gatt_char(write_characteristic, payload, response=False)
    state = await _wait_for_notification(
        notifications,
        settings.mode,
        settings.notify_timeout,
        long_state=True,
    )
    if state is None:
        LOG.error("FFE4 notification did not confirm %s mode", settings.mode)
        return False
    LOG.info("%s mode confirmed by FFE4 notification", settings.mode)
    return True


def _drain_notifications(notifications: asyncio.Queue[bytes]) -> None:
    while not notifications.empty():
        notifications.get_nowait()


async def _with_bleak_device_client_once(device: Any, settings: Settings, ensure: bool) -> bool:
    notifications: asyncio.Queue[bytes] = asyncio.Queue()

    def on_notification(_sender: Any, data: bytearray) -> None:
        notifications.put_nowait(bytes(data))

    LOG.info("connecting to %s", device.address)
    async with BleakClient(device, timeout=settings.connect_timeout) as client:
        write_characteristic = find_characteristic(client.services, WRITE_UUID)
        notify_characteristic = find_characteristic(client.services, NOTIFY_UUID)
        await client.start_notify(notify_characteristic, on_notification)
        try:
            if ensure:
                state = await _read_state(
                    client, write_characteristic, notifications, settings
                )
                if state is not None and notification_mode(state) == settings.mode:
                    LOG.info("device already uses %s mode", settings.mode)
                    return True
                if state is None:
                    LOG.error("FFE4 did not report the current mode")
                    return False
            else:
                _drain_notifications(notifications)
            return await _write_mode(
                client,
                write_characteristic,
                notifications,
                settings,
            )
        finally:
            await client.stop_notify(notify_characteristic)


def _normalize_gattlib_notification(data: bytes | str) -> bytes:
    raw = data.encode("latin1") if isinstance(data, str) else bytes(data)
    if raw[:1] in (b"\x1b", b"\x1d") and len(raw) >= 3:
        return raw[3:]
    return raw


def _gattlib_wait_for_notification(
    notifications: queue.Queue[bytes],
    mode: str | None,
    timeout: float,
    long_state: bool = False,
) -> bytes | None:
    deadline = time.monotonic() + timeout
    while True:
        remaining = deadline - time.monotonic()
        if remaining <= 0:
            return None
        try:
            value = notifications.get(timeout=remaining)
        except queue.Empty:
            return None
        LOG.info("FFE4 notify: %s", hex_bytes(value))
        detected_mode = notification_mode(value)
        if (
            detected_mode is not None
            and (mode is None or detected_mode == mode)
            and (not long_state or is_long_state_notification(value, detected_mode))
        ):
            return value


def _gattlib_transaction(address: str, settings: Settings, ensure: bool) -> bool:
    if gattlib is None:
        raise RuntimeError("gattlib is not installed")

    notifications: queue.Queue[bytes] = queue.Queue()

    class Requester(gattlib.GATTRequester):
        def on_notification(self, handle: int, data: bytes) -> None:
            value = _normalize_gattlib_notification(data)
            LOG.info("FFE4 gattlib notify handle=0x%04x: %s", handle, hex_bytes(value))
            notifications.put(value)

    requester = Requester(address, False)
    try:
        requester.connect()
        deadline = time.monotonic() + settings.connect_timeout
        while not requester.is_connected() and time.monotonic() < deadline:
            time.sleep(0.1)
        if not requester.is_connected():
            raise RuntimeError("gattlib connection timed out")
        characteristics = {
            item["uuid"].lower(): item
            for item in requester.discover_characteristics()
        }
        notify = characteristics[_full_uuid(NOTIFY_UUID)]
        write = characteristics[_full_uuid(WRITE_UUID)]
        descriptors = requester.discover_descriptors(
            notify["handle"], write["handle"] - 1
        )
        cccd = next(
            item
            for item in descriptors
            if item["uuid"].lower() == CCCD_UUID
        )
        requester.enable_notifications(cccd["handle"], True, False)
        time.sleep(0.5)
        LOG.info(
            "FFE4 notifications enabled through CCCD 0x%04x",
            cccd["handle"],
        )

        if ensure:
            while True:
                try:
                    notifications.get_nowait()
                except queue.Empty:
                    break
            requester.write_cmd(write["value_handle"], STATE_QUERY_PAYLOAD)
            state = _gattlib_wait_for_notification(
                notifications, None, settings.notify_timeout, long_state=True
            )
            if state is not None and notification_mode(state) == settings.mode:
                LOG.info("device already uses %s mode", settings.mode)
                return True
            if state is None:
                LOG.error("FFE4 did not report the current mode")
                return False
        else:
            while True:
                try:
                    notifications.get_nowait()
                except queue.Empty:
                    break

        payload = mode_payload(settings.mode)
        LOG.info("writing %s mode to FFE9: %s", settings.mode, hex_bytes(payload))
        requester.write_cmd(write["value_handle"], payload)
        state = _gattlib_wait_for_notification(
            notifications, settings.mode, settings.notify_timeout, long_state=True
        )
        if state is None:
            LOG.error("FFE4 notification did not confirm %s mode", settings.mode)
            return False
        LOG.info("%s mode confirmed by FFE4 notification", settings.mode)
        time.sleep(0.2)
        return True
    finally:
        requester.disconnect()


async def _with_device_client_once(device: Any, settings: Settings, ensure: bool) -> bool:
    try:
        return await _with_bleak_device_client_once(device, settings, ensure)
    except RuntimeError as error:
        if gattlib is None or "BLE characteristic not found" not in str(error):
            raise
        LOG.warning("Bleak exposed no GATT services; using gattlib fallback")
        return await asyncio.to_thread(
            _gattlib_transaction, str(device.address), settings, ensure
        )


async def _with_device_client(device: Any, settings: Settings, ensure: bool) -> bool:
    try:
        return await _with_device_client_once(device, settings, ensure)
    except Exception as error:
        LOG.warning("BLE transaction failed; will continue scanning: %s", error)
        return False


async def restore_device(device: Any, settings: Settings) -> bool:
    return await _with_device_client(device, settings, ensure=False)


async def ensure_device(device: Any, settings: Settings) -> bool:
    try:
        return await _with_device_client_once(device, settings, ensure=True)
    except Exception as error:
        LOG.warning("BLE startup transaction failed; retrying next scan: %s", error)
        raise TransientBleError from error


async def restore_once(settings: Settings) -> bool:
    device = await discover_target(settings)
    if device is None:
        LOG.error("target device not found")
        return False
    if not identity_confident(device, settings):
        LOG.error("refusing to write: BLE address identity was not verified")
        return False
    return await ensure_device(device, settings)


def scheduled_check_key(now: datetime, days: tuple[int, ...], check_time: str) -> str | None:
    configured = datetime.strptime(check_time, "%H:%M").time()
    if now.weekday() not in days:
        return None
    if now.hour != configured.hour or now.minute != configured.minute:
        return None
    return f"{now.date()} {check_time}"


def mode_check_due(now: datetime, last_check: datetime | None, interval: float) -> bool:
    return last_check is None or (now - last_check).total_seconds() >= interval


async def monitor(settings: Settings, startup_check: bool = True) -> None:
    state = load_monitor_state(settings.state_file)
    persistence_healthy = True
    durable_absence = state == "absent"
    startup_check_pending = startup_check
    last_mode_check: datetime | None = None
    last_scheduled_check: str | None = None
    absent_count = 0

    LOG.info("monitoring %s; target mode=%s; state=%s", settings.name, settings.mode, state)
    while True:
        now = datetime.now()
        scheduled_key = scheduled_check_key(
            now, settings.recovery_days, settings.scheduled_check_time
        )
        scheduled_due = (
            scheduled_key is not None and scheduled_key != last_scheduled_check
        )
        hourly_due = mode_check_due(now, last_mode_check, settings.mode_check_interval)
        if not startup_check_pending and not scheduled_due and not hourly_due:
            await asyncio.sleep(settings.scan_interval)
            continue

        scan_time = now
        last_mode_check = scan_time
        if scheduled_key is not None:
            last_scheduled_check = scheduled_key
        startup_pass = startup_check_pending
        startup_check_pending = False
        try:
            device = await discover_target(settings)
        except TransientBleError:
            LOG.warning("BLE discovery unavailable; preserving monitor state")
            continue

        if startup_pass and device is not None:
            if not identity_confident(device, settings):
                LOG.info("startup mode check waiting for the verified BLE address")
            elif not persistence_healthy:
                LOG.warning("startup mode check blocked by non-durable state")
            elif state == "absent" and not durable_absence:
                LOG.warning("startup mode check blocked by non-durable outage evidence")
            else:
                if state == "absent":
                    if not save_monitor_state(settings.state_file, "present"):
                        persistence_healthy = False
                        LOG.error("state is not durable; refusing the startup mode check")
                        continue
                    state = "present"
                    durable_absence = False
                try:
                    startup_ok = await ensure_device(device, settings)
                except TransientBleError:
                    continue
                if startup_ok:
                    if state != "present":
                        state = "present"
                        persistence_healthy = save_monitor_state(settings.state_file, state)
                    LOG.info("startup mode check complete")
                else:
                    LOG.error("startup mode check failed; hourly mode checks remain enabled")
                continue

        previous_state = state
        state, absent_count, recovered = monitor_transition(
            state,
            device is not None,
            absent_count,
            settings.absent_scans,
        )
        mode_checked = False
        if device is None:
            if state == "absent" and (
                state != previous_state or not persistence_healthy or not durable_absence
            ):
                saved = save_monitor_state(settings.state_file, state)
                persistence_healthy = saved
                if saved:
                    durable_absence = True
            if previous_state == "present":
                LOG.info(
                    "target absent (%d/%d scans)",
                    absent_count,
                    settings.absent_scans,
                )
            if state == "absent" and previous_state != "absent":
                LOG.info("target considered powered off")
        elif recovered:
            mode_checked = True
            if not durable_absence:
                state = "absent"
                LOG.warning("recovery evidence is not durably recorded; no write")
            elif not persistence_healthy:
                state = "absent"
                LOG.warning("recovery state is not durable; no write")
            elif not recovery_window_open(
                settings.recovery_days,
                settings.recovery_window_start,
                settings.recovery_window_end,
            ):
                state = "present"
                durable_absence = False
                persistence_healthy = save_monitor_state(settings.state_file, state)
                LOG.info("target returned outside the configured recovery window; no write")
            elif not identity_confident(device, settings):
                state = "present"
                durable_absence = False
                persistence_healthy = save_monitor_state(settings.state_file, state)
                LOG.warning("target returned with an unverified BLE identity; no write")
            elif not save_monitor_state(settings.state_file, "present"):
                persistence_healthy = False
                state = "absent"
                LOG.error("state is not durable; refusing the recovery write")
            else:
                durable_absence = False
                LOG.info(
                    "target returned; waiting %.1f seconds before restoring %s mode",
                    settings.recovery_delay,
                    settings.mode,
                )
                await asyncio.sleep(settings.recovery_delay)
                if not await restore_device(device, settings):
                    LOG.error("restore failed; will not retry until the next outage")
        elif state != previous_state:
            persistence_healthy = save_monitor_state(settings.state_file, state)
        elif previous_state == "unknown":
            LOG.info("target present; establishing baseline without writing")

        if (
            device is not None
            and not mode_checked
            and identity_confident(device, settings)
        ):
            reason = "scheduled" if scheduled_due else "hourly"
            LOG.info("running %s mode check", reason)
            try:
                mode_ok = await ensure_device(device, settings)
            except TransientBleError:
                mode_ok = False
            if mode_ok:
                LOG.info("%s mode check complete", reason)
            else:
                LOG.warning("%s mode check did not confirm %s mode", reason, settings.mode)


def parse_recovery_days(value: str) -> tuple[int, ...]:
    try:
        days = tuple(int(day) for day in value.split(",") if day != "")
    except ValueError as error:
        raise argparse.ArgumentTypeError("recovery days must be comma-separated integers") from error
    if not days or any(day < 0 or day > 6 for day in days):
        raise argparse.ArgumentTypeError("recovery days must be integers from 0 to 6")
    return days


def read_identity_file(path: str, label: str) -> str:
    try:
        value = Path(path).read_text(encoding="utf-8").strip()
    except OSError as error:
        raise ValueError(f"could not read {label} from {path}") from error
    if not value:
        raise ValueError(f"{label} file is empty: {path}")
    return value


def resolve_identity(value: str | None, path: str | None, label: str) -> str:
    if value and path:
        raise ValueError(f"use either --{label} or --{label}-file")
    if path:
        return read_identity_file(path, label)
    if value:
        return value
    raise ValueError(f"--{label} or --{label}-file is required")


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=sorted(MODES), default="auto")
    parser.add_argument("--address")
    parser.add_argument("--address-file")
    parser.add_argument("--name")
    parser.add_argument("--name-file")
    parser.add_argument("--scan-timeout", type=float, default=8.0)
    parser.add_argument("--scan-interval", type=float, default=10.0)
    parser.add_argument(
        "--absent-scans",
        type=int,
        default=3,
        help="consecutive missed scans required before a return is a recovery event",
    )
    parser.add_argument("--recovery-delay", type=float, default=5.0)
    parser.add_argument("--recovery-days", type=parse_recovery_days, default="1,3,5")
    parser.add_argument("--recovery-window-start", default="19:20")
    parser.add_argument("--recovery-window-end", default="19:45")
    parser.add_argument("--connect-timeout", type=float, default=15.0)
    parser.add_argument("--notify-timeout", type=float, default=5.0)
    parser.add_argument("--mode-check-interval", type=float, default=3600.0)
    parser.add_argument("--scheduled-check-time", default="19:32")
    parser.add_argument("--state-file")
    parser.add_argument(
        "--once",
        action="store_true",
        help="find the device, set the mode once, and exit",
    )
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


async def _run_restore_once(settings: Settings) -> bool:
    return await restore_once(settings)


async def _run_monitor(settings: Settings) -> None:
    await monitor(settings)


def main() -> int:
    args = parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )
    settings = Settings(
        mode=args.mode,
        address=resolve_identity(args.address, args.address_file, "address"),
        name=resolve_identity(args.name, args.name_file, "name"),
        scan_timeout=args.scan_timeout,
        scan_interval=args.scan_interval,
        absent_scans=max(1, args.absent_scans),
        recovery_delay=max(0.0, args.recovery_delay),
        recovery_days=args.recovery_days,
        recovery_window_start=args.recovery_window_start,
        recovery_window_end=args.recovery_window_end,
        connect_timeout=args.connect_timeout,
        notify_timeout=args.notify_timeout,
        mode_check_interval=max(1.0, args.mode_check_interval),
        scheduled_check_time=args.scheduled_check_time,
        state_file=args.state_file,
    )

    try:
        if args.once:
            return 0 if asyncio.run(_run_restore_once(settings)) else 1
        asyncio.run(_run_monitor(settings))
    except KeyboardInterrupt:
        LOG.info("stopped")
    except Exception:
        LOG.exception("BLE gateway failed")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
