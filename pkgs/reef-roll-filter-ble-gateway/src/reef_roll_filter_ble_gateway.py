#!/usr/bin/env python3
"""Restore a paper-reel BLE device to a configured operating mode."""

from __future__ import annotations

import argparse
import asyncio
import json
import logging
import os
from dataclasses import dataclass
from datetime import datetime
from pathlib import Path
from typing import Any

from bleak import BleakClient, BleakScanner  # type: ignore[import-not-found]

LOG = logging.getLogger("reef-roll-filter-ble-gateway")

DEVICE_NAME = "Paper_reel_REDACTED"
WRITE_UUID = "0000ffe9-0000-1000-8000-00805f9b34fb"
NOTIFY_UUID = "0000ffe4-0000-1000-8000-00805f9b34fb"

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


async def discover_target(settings: Settings) -> Any | None:
    discovered = await BleakScanner.discover(
        timeout=settings.scan_timeout,
        return_adv=True,
    )
    if isinstance(discovered, dict):
        entries = discovered.values()
    else:
        entries = ((device, None) for device in discovered)

    for device, advertisement in entries:
        if matches_device(device, advertisement, settings.address, settings.name):
            LOG.info(
                "found %s (%s)",
                _advertisement_name(device, advertisement) or "unnamed device",
                device.address,
            )
            return device
    return None


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
    state_file: str | None


async def _read_state(client: Any, characteristic: Any, settings: Settings) -> bytes | None:
    try:
        state = bytes(
            await asyncio.wait_for(
                client.read_gatt_char(characteristic),
                settings.notify_timeout,
            )
        )
    except Exception:
        LOG.exception("could not read FFE4 state")
        return None
    LOG.info("FFE4 read state: %s", hex_bytes(state))
    return state


async def _write_mode(
    client: Any,
    write_characteristic: Any,
    notify_characteristic: Any,
    settings: Settings,
) -> bool:
    payload = mode_payload(settings.mode)
    expected = set(expected_notifications(settings.mode))
    LOG.info("writing %s mode to FFE9: %s", settings.mode, hex_bytes(payload))
    await client.write_gatt_char(write_characteristic, payload, response=False)
    state = await _read_state(client, notify_characteristic, settings)
    if state not in expected:
        LOG.error("FFE4 state did not confirm %s mode", settings.mode)
        return False
    LOG.info("%s mode confirmed by FFE4 read", settings.mode)
    return True


async def _with_device_client(device: Any, settings: Settings, ensure: bool) -> bool:
    def on_notification(_sender: Any, data: bytearray) -> None:
        LOG.info("FFE4 notify: %s", hex_bytes(bytes(data)))

    LOG.info("connecting to %s", device.address)
    async with BleakClient(device, timeout=settings.connect_timeout) as client:
        write_characteristic = find_characteristic(client.services, WRITE_UUID)
        notify_characteristic = find_characteristic(client.services, NOTIFY_UUID)
        await client.start_notify(notify_characteristic, on_notification)
        try:
            if ensure:
                state = await _read_state(client, notify_characteristic, settings)
                if state in set(expected_notifications(settings.mode)):
                    LOG.info("device already uses %s mode", settings.mode)
                    return True
                if state is None:
                    return False
            return await _write_mode(
                client,
                write_characteristic,
                notify_characteristic,
                settings,
            )
        finally:
            await client.stop_notify(notify_characteristic)


async def restore_device(device: Any, settings: Settings) -> bool:
    return await _with_device_client(device, settings, ensure=False)


async def ensure_device(device: Any, settings: Settings) -> bool:
    return await _with_device_client(device, settings, ensure=True)


async def restore_once(settings: Settings) -> bool:
    device = await discover_target(settings)
    if device is None:
        LOG.error("target device not found")
        return False
    if not identity_confident(device, settings):
        LOG.error("refusing to write: BLE address identity was not verified")
        return False
    return await ensure_device(device, settings)


async def monitor(settings: Settings, startup_check: bool = True) -> None:
    state = load_monitor_state(settings.state_file)
    persistence_healthy = True
    durable_absence = state == "absent"
    startup_check_pending = startup_check
    absent_count = 0

    LOG.info("monitoring %s; target mode=%s; state=%s", settings.name, settings.mode, state)
    while True:
        device = await discover_target(settings)
        if startup_check_pending and device is not None:
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
                        await asyncio.sleep(settings.scan_interval)
                        continue
                    state = "present"
                    durable_absence = False
                startup_check_pending = False
                if await ensure_device(device, settings):
                    if state != "present":
                        state = "present"
                        persistence_healthy = save_monitor_state(settings.state_file, state)
                    LOG.info("startup mode check complete")
                else:
                    LOG.error("startup mode check failed; no automatic retry this boot")
                await asyncio.sleep(settings.scan_interval)
                continue

        previous_state = state
        state, absent_count, recovered = monitor_transition(
            state,
            device is not None,
            absent_count,
            settings.absent_scans,
        )
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

        await asyncio.sleep(settings.scan_interval)


def parse_recovery_days(value: str) -> tuple[int, ...]:
    try:
        days = tuple(int(day) for day in value.split(",") if day != "")
    except ValueError as error:
        raise argparse.ArgumentTypeError("recovery days must be comma-separated integers") from error
    if not days or any(day < 0 or day > 6 for day in days):
        raise argparse.ArgumentTypeError("recovery days must be integers from 0 to 6")
    return days


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--mode", choices=sorted(MODES), default="auto")
    parser.add_argument("--address", default="AA:BB:CC:DD:EE:FF")
    parser.add_argument("--name", default=DEVICE_NAME)
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
    parser.add_argument("--state-file")
    parser.add_argument(
        "--once",
        action="store_true",
        help="find the device, set the mode once, and exit",
    )
    parser.add_argument("--verbose", action="store_true")
    return parser.parse_args()


def main() -> int:
    args = parse_args()
    logging.basicConfig(
        level=logging.DEBUG if args.verbose else logging.INFO,
        format="%(asctime)s %(levelname)s %(message)s",
    )
    settings = Settings(
        mode=args.mode,
        address=args.address,
        name=args.name,
        scan_timeout=args.scan_timeout,
        scan_interval=args.scan_interval,
        absent_scans=max(1, args.absent_scans),
        recovery_delay=max(0.0, args.recovery_delay),
        recovery_days=args.recovery_days,
        recovery_window_start=args.recovery_window_start,
        recovery_window_end=args.recovery_window_end,
        connect_timeout=args.connect_timeout,
        notify_timeout=args.notify_timeout,
        state_file=args.state_file,
    )

    try:
        if args.once:
            return 0 if asyncio.run(restore_once(settings)) else 1
        asyncio.run(monitor(settings))
    except KeyboardInterrupt:
        LOG.info("stopped")
    except Exception:
        LOG.exception("BLE gateway failed")
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
