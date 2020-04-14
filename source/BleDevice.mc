// vim: syntax=c

using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

hidden const LBS_SERVICE = "00001523-1212-efde-1523-785feabcd123";
hidden const LBS_LED_CHAR = "00001525-1212-efde-1523-785feabcd123";

class BleDevice extends Ble.BleDelegate {
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
			:uuid => Ble.stringToUuid(LBS_SERVICE),
			:characteristics => [{
				:uuid => Ble.stringToUuid(LBS_LED_CHAR)
			}]
		};

		BluetoothLowEnergy.registerProfile(profile);
	}

	function onScanStateChange(scanState, status) {
		debug("scanstate: " + scanState + " " + status);
	}

	function start() {
		registerProfiles();
		Ble.setScanState(Ble.SCAN_STATE_SCANNING);
	}
}
