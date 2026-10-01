import pathlib
import runpy
import sys
import tempfile
import types
import unittest
from datetime import datetime
from typing import Any


class BleakStub(types.ModuleType):
    BleakClient = object
    BleakScanner = object


sys.modules["bleak"] = BleakStub("bleak")

SOURCE = pathlib.Path(__file__).parents[1] / "src" / "reef_roll_filter_ble_gateway.py"
MODULE = runpy.run_path(str(SOURCE))


def settings(mode="auto", state_file=None):
    return MODULE["Settings"](
        mode=mode,
        address="AA:BB:CC:DD:EE:FF",
        name="Paper_reel_REDACTED",
        scan_timeout=0.01,
        scan_interval=0.01,
        absent_scans=2,
        recovery_delay=0,
        recovery_days=(1, 3, 5),
        recovery_window_start="19:20",
        recovery_window_end="19:45",
        connect_timeout=0.01,
        notify_timeout=0.01,
        state_file=state_file,
    )


class FakeCharacteristic:
    def __init__(self, uuid):
        self.uuid = uuid


class FakeBleakClient:
    prewrite_notification = False
    during_write_notification = False
    postwrite_notification = False
    read_payload = b""
    configured_read_payloads: tuple[bytes, ...] = ()
    last_instance: Any = None

    def __init__(self, device, timeout):
        self.device = device
        self.timeout = timeout
        self.callback: Any = None
        self.read_payloads: list[bytes] = list(type(self).configured_read_payloads)
        self.writes = []
        self.services = [
            types.SimpleNamespace(
                characteristics=[
                    FakeCharacteristic(MODULE["WRITE_UUID"]),
                    FakeCharacteristic(MODULE["NOTIFY_UUID"]),
                ]
            )
        ]
        type(self).last_instance = self

    async def __aenter__(self):
        return self

    async def __aexit__(self, *_args):
        return None

    async def start_notify(self, _characteristic, callback):
        self.callback = callback
        if type(self).prewrite_notification:
            callback(None, bytearray(MODULE["expected_notifications"]("auto")[0]))

    async def stop_notify(self, _characteristic):
        return None

    async def write_gatt_char(self, characteristic, payload, response):
        self.writes.append((characteristic.uuid, bytes(payload), response))
        if type(self).during_write_notification:
            self.callback(None, bytearray(MODULE["expected_notifications"]("auto")[0]))

    async def read_gatt_char(self, _characteristic):
        if self.read_payloads:
            return self.read_payloads.pop(0)
        return type(self).read_payload


class ModePayloadTests(unittest.TestCase):
    def test_all_modes_use_the_observed_ten_byte_command(self):
        expected = {
            "auto": "5054000605f801010000",
            "timer": "5054000605f801020000",
            "eco": "5054000605f801030000",
            "clean": "5054000605f801040000",
        }
        for mode, payload in expected.items():
            with self.subTest(mode=mode):
                self.assertEqual(MODULE["mode_payload"](mode).hex(), payload)

    def test_expected_notifications_match_the_mode(self):
        short, long = MODULE["expected_notifications"]("eco")
        self.assertEqual(short.hex(), "5250000605f801030000")
        self.assertEqual(long.hex(), "5254000d0c310300006401000005010101")

    def test_invalid_mode_is_rejected(self):
        with self.assertRaises(ValueError):
            MODULE["mode_payload"]("unknown")

    def test_recovery_window_requires_configured_day_and_time(self):
        self.assertTrue(
            MODULE["recovery_window_open"](
                (1, 3, 5), "19:20", "19:45", datetime(2026, 9, 29, 19, 30)
            )
        )
        self.assertFalse(
            MODULE["recovery_window_open"](
                (1, 3, 5), "19:20", "19:45", datetime(2026, 9, 29, 18, 30)
            )
        )
        self.assertFalse(
            MODULE["recovery_window_open"](
                (1, 3, 5), "19:20", "19:45", datetime(2026, 9, 30, 19, 30)
            )
        )


class MonitorStateTests(unittest.TestCase):
    def test_outage_requires_two_missed_scans(self):
        self.assertEqual(
            MODULE["monitor_transition"]("present", False, 0, 2),
            ("present", 1, False),
        )
        self.assertEqual(
            MODULE["monitor_transition"]("present", False, 1, 2),
            ("absent", 2, False),
        )

    def test_return_from_persisted_outage_is_a_recovery(self):
        self.assertEqual(
            MODULE["monitor_transition"]("absent", True, 2, 2),
            ("present", 0, True),
        )

    def test_unknown_start_does_not_write_on_first_sighting(self):
        self.assertEqual(
            MODULE["monitor_transition"]("unknown", True, 0, 2),
            ("present", 0, False),
        )

    def test_state_file_survives_restart(self):
        with tempfile.TemporaryDirectory() as directory:
            path = f"{directory}/state.json"
            self.assertTrue(MODULE["save_monitor_state"](path, "absent"))
            self.assertEqual(MODULE["load_monitor_state"](path), "absent")

    def test_state_persistence_failure_is_reported(self):
        with tempfile.NamedTemporaryFile() as path:
            self.assertFalse(MODULE["save_monitor_state"](f"{path.name}/state", "present"))

    def test_device_matching_accepts_address_or_exact_name(self):
        device = types.SimpleNamespace(
            address="AA:BB:CC:DD:EE:FF",
            name="Paper_reel_REDACTED",
        )
        advertisement = types.SimpleNamespace(local_name=device.name)
        self.assertTrue(
            MODULE["matches_device"](
                device,
                advertisement,
                "AA:BB:CC:DD:EE:FF",
                "Paper_reel_REDACTED",
            )
        )
        self.assertTrue(
            MODULE["matches_device"](
                types.SimpleNamespace(address="random", name=None),
                advertisement,
                "",
                "Paper_reel_REDACTED",
            )
        )
        name_only_device = types.SimpleNamespace(address="random", name=None)
        self.assertFalse(
            MODULE["identity_confident"](name_only_device, settings())
        )
        self.assertFalse(
            MODULE["matches_device"](
                types.SimpleNamespace(address="random", name="other"),
                advertisement,
                "",
                "Paper_reel_REDACTED",
            )
        )


class MonitorBehaviorTests(unittest.IsolatedAsyncioTestCase):
    async def test_failed_absent_save_requires_a_later_durable_absence(self):
        with tempfile.TemporaryDirectory() as directory:
            path = f"{directory}/state.json"
            MODULE["save_monitor_state"](path, "present")
            device = types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF")
            globals_dict = MODULE["monitor"].__globals__
            originals = {
                name: globals_dict[name]
                for name in (
                    "discover_target",
                    "save_monitor_state",
                    "restore_device",
                    "recovery_window_open",
                    "asyncio",
                )
            }
            discoveries = iter((None, None, device, device, None, None, device))
            save_results = iter((False, True, True))
            save_states = []
            restore_calls = []
            sleep_calls = 0

            async def discover(_settings):
                return next(discoveries)

            def save(_path, state):
                save_states.append(state)
                return next(save_results)

            async def restore(_device, _settings):
                restore_calls.append(True)
                return True

            def recovery_window(*_args):
                return True

            async def stop_after_eight(_seconds):
                nonlocal sleep_calls
                sleep_calls += 1
                if sleep_calls == 8:
                    raise RuntimeError("stop test monitor")

            globals_dict.update(
                discover_target=discover,
                save_monitor_state=save,
                restore_device=restore,
                recovery_window_open=recovery_window,
                asyncio=types.SimpleNamespace(sleep=stop_after_eight),
            )
            try:
                with self.assertRaises(RuntimeError):
                    await MODULE["monitor"](settings(state_file=path), startup_check=False)
            finally:
                globals_dict.update(originals)
            self.assertEqual(save_states, ["absent", "absent", "present"])
            self.assertEqual(restore_calls, [True])

    async def test_failed_present_save_blocks_until_absence_is_durable_again(self):
        with tempfile.TemporaryDirectory() as directory:
            path = f"{directory}/state.json"
            MODULE["save_monitor_state"](path, "absent")
            device = types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF")
            globals_dict = MODULE["monitor"].__globals__
            originals = {
                name: globals_dict[name]
                for name in (
                    "discover_target",
                    "save_monitor_state",
                    "restore_device",
                    "recovery_window_open",
                    "asyncio",
                )
            }
            discoveries = iter((device, device, None, None, device))
            save_results = iter((False, True, True))
            save_states = []
            restore_calls = []
            sleep_calls = 0

            async def discover(_settings):
                return next(discoveries)

            def save(_path, state):
                save_states.append(state)
                return next(save_results)

            async def restore(_device, _settings):
                restore_calls.append(True)
                return True

            def recovery_window(*_args):
                return True

            async def stop_after_six(_seconds):
                nonlocal sleep_calls
                sleep_calls += 1
                if sleep_calls == 6:
                    raise RuntimeError("stop test monitor")

            globals_dict.update(
                discover_target=discover,
                save_monitor_state=save,
                restore_device=restore,
                recovery_window_open=recovery_window,
                asyncio=types.SimpleNamespace(sleep=stop_after_six),
            )
            try:
                with self.assertRaises(RuntimeError):
                    await MODULE["monitor"](settings(state_file=path), startup_check=False)
            finally:
                globals_dict.update(originals)
            self.assertEqual(save_states, ["present", "absent", "present"])
            self.assertEqual(restore_calls, [True])

    async def test_out_of_window_return_is_handled_without_later_write(self):
        with tempfile.TemporaryDirectory() as directory:
            path = f"{directory}/state.json"
            MODULE["save_monitor_state"](path, "absent")
            device = types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF")
            globals_dict = MODULE["monitor"].__globals__
            originals = {
                name: globals_dict[name]
                for name in (
                    "discover_target",
                    "save_monitor_state",
                    "restore_device",
                    "recovery_window_open",
                    "asyncio",
                )
            }
            discoveries = iter((device, device))
            save_states = []
            restore_calls = []
            window_results = iter((False, True))
            sleep_calls = 0

            async def discover(_settings):
                return next(discoveries)

            def save(_path, state):
                save_states.append(state)
                return True

            async def restore(_device, _settings):
                restore_calls.append(True)
                return True

            def recovery_window(*_args):
                return next(window_results)

            async def stop_after_two(_seconds):
                nonlocal sleep_calls
                sleep_calls += 1
                if sleep_calls == 2:
                    raise RuntimeError("stop test monitor")

            globals_dict.update(
                discover_target=discover,
                save_monitor_state=save,
                restore_device=restore,
                recovery_window_open=recovery_window,
                asyncio=types.SimpleNamespace(sleep=stop_after_two),
            )
            try:
                with self.assertRaises(RuntimeError):
                    await MODULE["monitor"](settings(state_file=path), startup_check=False)
            finally:
                globals_dict.update(originals)
            self.assertEqual(save_states, ["present"])
            self.assertEqual(restore_calls, [])


class RestoreDeviceTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.globals = MODULE["restore_device"].__globals__
        self.original_client = self.globals["BleakClient"]
        self.globals["BleakClient"] = FakeBleakClient
        FakeBleakClient.prewrite_notification = False
        FakeBleakClient.during_write_notification = False
        FakeBleakClient.postwrite_notification = False
        FakeBleakClient.read_payload = b""
        FakeBleakClient.configured_read_payloads = ()

    def tearDown(self):
        self.globals["BleakClient"] = self.original_client

    async def test_notification_during_write_cannot_confirm_stale_read_state(self):
        FakeBleakClient.during_write_notification = True
        FakeBleakClient.read_payload = MODULE["expected_notifications"]("clean")[0]
        result = await MODULE["restore_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertFalse(result)
        self.assertEqual(len(FakeBleakClient.last_instance.writes), 1)

    async def test_matching_postwrite_read_confirms(self):
        FakeBleakClient.read_payload = MODULE["expected_notifications"]("auto")[0]
        result = await MODULE["restore_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertTrue(result)
        self.assertEqual(
            FakeBleakClient.last_instance.writes[0][1],
            bytes.fromhex("5054000605F801010000"),
        )
        self.assertFalse(FakeBleakClient.last_instance.writes[0][2])

    async def test_startup_check_skips_write_when_mode_matches(self):
        FakeBleakClient.read_payload = MODULE["expected_notifications"]("auto")[0]
        result = await MODULE["ensure_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertTrue(result)
        self.assertEqual(FakeBleakClient.last_instance.writes, [])

    async def test_startup_check_writes_when_mode_differs(self):
        FakeBleakClient.configured_read_payloads = (
            MODULE["expected_notifications"]("clean")[0],
            MODULE["expected_notifications"]("auto")[0],
        )
        result = await MODULE["ensure_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertTrue(result)
        self.assertEqual(len(FakeBleakClient.last_instance.writes), 1)


if __name__ == "__main__":
    unittest.main()
