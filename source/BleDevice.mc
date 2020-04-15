// vim: syntax=c

using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

hidden const DEVICE_NAME = "Nordic_Blinky";
hidden const LBS_SERVICE = Ble.stringToUuid("00001523-1212-efde-1523-785feabcd123");
hidden const LBS_LED_CHAR = Ble.stringToUuid("00001525-1212-efde-1523-785feabcd123");

class BleDevice extends Ble.BleDelegate {
	var scanning = false;
	var device = null;

	hidden function debug(str) {
		System.println("[ble] " + str);
	}

	function initialize() {
		BleDelegate.initialize();
		debug("initialize");
	}

	function onProfileRegister(uuid, status) {
		debug("registered: " + uuid + " " + status);
	}

	function registerProfiles() {
		var profile = {
			:uuid => LBS_SERVICE,
			:characteristics => [{
				:uuid => LBS_LED_CHAR
			}]
		};

		BluetoothLowEnergy.registerProfile(profile);
	}

	function onScanStateChange(scanState, status) {
		debug("scanstate: " + scanState + " " + status);
	}

	function onConnectedStateChanged(device, state) {
		debug("connected: " + device.getName() + " " + state);
		if (state == Ble.CONNECTION_STATE_CONNECTED) {
			self.device = device;
		} else {
			self.device = null;
		}
	}

	private function connect(result) {
		debug("connect");
		scanning = false;
		Ble.setScanState(Ble.SCAN_STATE_OFF);
		Ble.pairDevice(result);
	}

	private function dumpUuids(iter) {
		for (var x = iter.next(); x != null; x = iter.next()) {
			debug("uuid: " + x);
		}
		return false;
	}

	function onScanResults(scanResults) {
		debug("scan results");
		var uuids;
		var name;
		var rssi;
		for (var result = scanResults.next(); result != null; result = scanResults.next()) {
			uuids = result.getServiceUuids();
			name = result.getDeviceName();
			rssi = result.getRssi();

			debug("device: " + name + " rssi: " + rssi);
			dumpUuids(uuids);

			if (name.equals(DEVICE_NAME)) {
				connect(result);
				return;
			}
		}
	}

	function open() {
		registerProfiles();
		scanning = true;
		Ble.setScanState(Ble.SCAN_STATE_SCANNING);
	}

	function close() {
		debug("close");
		if (scanning) {
			Ble.setScanState(Ble.SCAN_STATE_OFF);
		}
		if (device) {
			Ble.unpairDevice(device);
		}
	}
}
