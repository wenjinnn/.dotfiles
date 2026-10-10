import asyncio
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
        name="Paper_reel_TEST",
        scan_timeout=0.01,
        scan_interval=0.01,
        absent_scans=2,
        recovery_delay=0,
        recovery_days=(1, 3, 5),
        recovery_window_start="19:20",
        recovery_window_end="19:45",
        connect_timeout=0.01,
        notify_timeout=0.01,
        mode_check_interval=0.0,
        scheduled_check_time="19:32",
        state_file=state_file,
    )


class FakeCharacteristic:
    def __init__(self, uuid):
        self.uuid = uuid


class FakeBleakClient:
    configured_notifications: tuple[bytes, ...] = ()
    query_notifications: tuple[bytes, ...] = ()
    during_write_notifications: tuple[bytes, ...] = ()
    last_instance: Any = None

    def __init__(self, device, timeout):
        self.device = device
        self.timeout = timeout
        self.callback: Any = None
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
        for value in type(self).configured_notifications:
            callback(None, bytearray(value))

    async def stop_notify(self, _characteristic):
        return None

    async def write_gatt_char(self, characteristic, payload, response):
        payload = bytes(payload)
        self.writes.append((characteristic.uuid, payload, response))
        if payload == MODULE["STATE_QUERY_PAYLOAD"]:
            notifications = type(self).query_notifications
        else:
            notifications = type(self).during_write_notifications
        for value in notifications:
            self.callback(None, bytearray(value))


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

    def test_dynamic_long_notification_confirms_mode(self):
        notification = bytes.fromhex("5254000D0C3104000064000C0005010101")
        self.assertEqual(MODULE["notification_mode"](notification), "clean")

    def test_gattlib_notification_strips_att_header(self):
        notification = bytes.fromhex("1B0E005250000605F801040000")
        self.assertEqual(
            MODULE["notification_mode"](
                MODULE["_normalize_gattlib_notification"](notification)
            ),
            "clean",
        )

    def test_query_state_notification_uses_rp_prefix(self):
        notification = bytes.fromhex("5250000D0C3101000064000C0005010101")
        self.assertEqual(MODULE["notification_mode"](notification), "auto")

    def test_scheduled_check_is_tuesday_thursday_saturday_at_1932(self):
        self.assertEqual(
            MODULE["scheduled_check_key"](
                datetime(2026, 10, 6, 19, 32), (1, 3, 5), "19:32"
            ),
            "2026-10-06 19:32",
        )
        self.assertIsNone(
            MODULE["scheduled_check_key"](
                datetime(2026, 10, 6, 19, 31), (1, 3, 5), "19:32"
            )
        )

    def test_hourly_mode_check_due(self):
        now = datetime(2026, 10, 6, 20, 32)
        self.assertTrue(MODULE["mode_check_due"](now, None, 3600))
        self.assertTrue(
            MODULE["mode_check_due"](now, datetime(2026, 10, 6, 19, 31), 3600)
        )
        self.assertFalse(
            MODULE["mode_check_due"](now, datetime(2026, 10, 6, 20, 0), 3600)
        )

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


class DiscoveryTests(unittest.IsolatedAsyncioTestCase):
    async def test_scan_is_one_shot_and_cleaned_up(self):
        globals_dict = MODULE["discover_target"].__globals__
        original_scanner = globals_dict["BleakScanner"]
        instances = []

        class WorkingScanner:
            def __init__(self, detection_callback):
                self.detection_callback = detection_callback
                self.stop_count = 0
                instances.append(self)

            async def start(self):
                self.detection_callback(
                    types.SimpleNamespace(
                        address="AA:BB:CC:DD:EE:FF",
                        name="Paper_reel_TEST",
                    ),
                    types.SimpleNamespace(local_name="Paper_reel_TEST"),
                )

            async def stop(self):
                self.stop_count += 1

        globals_dict["BleakScanner"] = WorkingScanner
        try:
            first = await MODULE["discover_target"](settings())
            second = await MODULE["discover_target"](settings())
            self.assertIsNotNone(first)
            self.assertIsNotNone(second)
            self.assertEqual(len(instances), 2)
            self.assertEqual([instance.stop_count for instance in instances], [1, 1])
        finally:
            globals_dict["BleakScanner"] = original_scanner

    async def test_empty_scan_is_not_treated_as_absence(self):
        globals_dict = MODULE["discover_target"].__globals__
        original_scanner = globals_dict["BleakScanner"]
        instance: Any = None

        class SilentScanner:
            def __init__(self, **_kwargs):
                nonlocal instance
                self.stop_count = 0
                instance = self

            async def start(self):
                return None

            async def stop(self):
                self.stop_count += 1

        globals_dict["BleakScanner"] = SilentScanner
        try:
            with self.assertRaises(MODULE["TransientBleError"]):
                await MODULE["discover_target"](settings())
            self.assertEqual(instance.stop_count, 1)
        finally:
            globals_dict["BleakScanner"] = original_scanner

    async def test_cancelled_start_stops_local_scanner(self):
        globals_dict = MODULE["discover_target"].__globals__
        original_scanner = globals_dict["BleakScanner"]
        started = asyncio.Event()
        instance: Any = None

        class BlockingScanner:
            def __init__(self, **_kwargs):
                nonlocal instance
                self.stop_count = 0
                instance = self

            async def start(self):
                started.set()
                await asyncio.Future()

            async def stop(self):
                self.stop_count += 1

        globals_dict["BleakScanner"] = BlockingScanner
        task = asyncio.create_task(MODULE["discover_target"](settings()))
        try:
            await started.wait()
            task.cancel()
            with self.assertRaises(asyncio.CancelledError):
                await task
            self.assertEqual(instance.stop_count, 1)
        finally:
            globals_dict["BleakScanner"] = original_scanner

    async def test_transient_scan_error_does_not_kill_monitor(self):
        globals_dict = MODULE["discover_target"].__globals__
        original_scanner = globals_dict["BleakScanner"]

        class FailingScanner:
            def __init__(self, **_kwargs):
                pass

            async def start(self):
                raise RuntimeError("org.bluez.Error.InProgress")

        globals_dict["BleakScanner"] = FailingScanner
        try:
            with self.assertRaises(MODULE["TransientBleError"]):
                await MODULE["discover_target"](settings())
        finally:
            globals_dict["BleakScanner"] = original_scanner


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
            name="Paper_reel_TEST",
        )
        advertisement = types.SimpleNamespace(local_name=device.name)
        self.assertTrue(
            MODULE["matches_device"](
                device,
                advertisement,
                "AA:BB:CC:DD:EE:FF",
                "Paper_reel_TEST",
            )
        )
        self.assertTrue(
            MODULE["matches_device"](
                types.SimpleNamespace(address="random", name=None),
                advertisement,
                "",
                "Paper_reel_TEST",
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
                "Paper_reel_TEST",
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

    async def test_discovery_failure_preserves_persisted_state(self):
        with tempfile.TemporaryDirectory() as directory:
            path = f"{directory}/state.json"
            MODULE["save_monitor_state"](path, "present")
            globals_dict = MODULE["monitor"].__globals__
            original_discover = globals_dict["discover_target"]
            original_save = globals_dict["save_monitor_state"]
            original_asyncio = globals_dict["asyncio"]
            attempts = 0
            saved_states = []

            async def discover(_settings):
                nonlocal attempts
                attempts += 1
                if attempts == 1:
                    raise MODULE["TransientBleError"]
                raise RuntimeError("stop test monitor")

            def save(_path, state):
                saved_states.append(state)
                return True

            async def stop_after_failure(_seconds):
                raise RuntimeError("stop test monitor")

            globals_dict["discover_target"] = discover
            globals_dict["save_monitor_state"] = save
            globals_dict["asyncio"] = types.SimpleNamespace(sleep=stop_after_failure)
            try:
                with self.assertRaises(RuntimeError):
                    await MODULE["monitor"](settings(state_file=path))
            finally:
                globals_dict["discover_target"] = original_discover
                globals_dict["save_monitor_state"] = original_save
                globals_dict["asyncio"] = original_asyncio
            self.assertEqual(saved_states, [])

    async def test_startup_ble_failure_retries_without_exiting_monitor(self):
        device = types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF")
        globals_dict = MODULE["monitor"].__globals__
        originals = {
            name: globals_dict[name]
            for name in ("discover_target", "ensure_device", "asyncio")
        }
        discoveries = iter((device, device))
        attempts = 0
        sleep_calls = 0

        async def discover(_settings):
            return next(discoveries)

        async def ensure(_device, _settings):
            nonlocal attempts
            attempts += 1
            if attempts == 1:
                raise MODULE["TransientBleError"]
            return True

        async def stop_after_two(_seconds):
            nonlocal sleep_calls
            sleep_calls += 1
            if sleep_calls == 2:
                raise RuntimeError("stop test monitor")

        globals_dict.update(
            discover_target=discover,
            ensure_device=ensure,
            asyncio=types.SimpleNamespace(sleep=stop_after_two),
        )
        try:
            with self.assertRaises(RuntimeError):
                await MODULE["monitor"](settings())
        finally:
            globals_dict.update(originals)
        self.assertEqual(attempts, 2)


class RestoreDeviceTests(unittest.IsolatedAsyncioTestCase):
    def setUp(self):
        self.globals = MODULE["restore_device"].__globals__
        self.original_client = self.globals["BleakClient"]
        self.globals["BleakClient"] = FakeBleakClient
        FakeBleakClient.configured_notifications = ()
        FakeBleakClient.query_notifications = ()
        FakeBleakClient.during_write_notifications = ()

    def tearDown(self):
        self.globals["BleakClient"] = self.original_client

    async def test_wrong_mode_notification_cannot_confirm_mode(self):
        FakeBleakClient.during_write_notifications = (
            MODULE["expected_notifications"]("clean")[0],
        )
        result = await MODULE["restore_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertFalse(result)
        self.assertEqual(len(FakeBleakClient.last_instance.writes), 1)

    async def test_matching_postwrite_state_notification_confirms(self):
        FakeBleakClient.during_write_notifications = MODULE["expected_notifications"]("auto")
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
        FakeBleakClient.query_notifications = MODULE["expected_notifications"]("auto")
        result = await MODULE["ensure_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertTrue(result)
        self.assertEqual(
            FakeBleakClient.last_instance.writes[0][1],
            MODULE["STATE_QUERY_PAYLOAD"],
        )
        self.assertEqual(len(FakeBleakClient.last_instance.writes), 1)

    async def test_startup_check_writes_when_mode_differs(self):
        FakeBleakClient.query_notifications = MODULE["expected_notifications"]("clean")
        FakeBleakClient.during_write_notifications = MODULE["expected_notifications"]("auto")
        result = await MODULE["ensure_device"](
            types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
        )
        self.assertTrue(result)
        self.assertEqual(len(FakeBleakClient.last_instance.writes), 2)
        self.assertEqual(
            FakeBleakClient.last_instance.writes[0][1],
            MODULE["STATE_QUERY_PAYLOAD"],
        )

    async def test_ble_transaction_failure_returns_false_without_crashing_monitor(self):
        original_find_characteristic = self.globals["find_characteristic"]

        def fail_find_characteristic(_services, _uuid):
            raise RuntimeError("services disappeared")

        self.globals["find_characteristic"] = fail_find_characteristic
        try:
            with self.assertRaises(MODULE["TransientBleError"]):
                await MODULE["ensure_device"](
                    types.SimpleNamespace(address="AA:BB:CC:DD:EE:FF"), settings()
                )
        finally:
            self.globals["find_characteristic"] = original_find_characteristic


if __name__ == "__main__":
    unittest.main()
