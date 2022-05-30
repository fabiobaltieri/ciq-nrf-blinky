// vim: syntax=c

using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

hidden const DEVICE_NAME = "Nordic_Blinky";
hidden const LBS_SERVICE = Ble.stringToUuid("00001523-1212-efde-1523-785feabcd123");
hidden const LBS_LED_CHAR = Ble.stringToUuid("00001525-1212-efde-1523-785feabcd123");
hidden const LBS_BUTTON_CHAR = Ble.stringToUuid("00001524-1212-efde-1523-785feabcd123");
hidden const LBS_BUTTON_DESC = Ble.cccdUuid();

class BleDevice extends Ble.BleDelegate {
	var scanning = false;
	var device = null;
	var button = 0;
	var scan_delay = 5;

	hidden function debug(str) {
		System.println("[ble] " + str);
	}

	function initialize() {
		BleDelegate.initialize();
		debug("initialize");
	}

	function setLed(value) {
		var service;
		var ch;

		if (device == null) {
			debug("setLed: not connected");
			return;
		}
		debug("setLed: " + value);

		service = device.getService(LBS_SERVICE);
		ch = service.getCharacteristic(LBS_LED_CHAR);
		try {
			ch.requestWrite([value & 0xff]b, {:writeType => Ble.WRITE_TYPE_DEFAULT});
		} catch (ex) {
			debug("setLed: can't start char read");
		}
	}

	function onCharacteristicChanged(ch, value) {
		debug("char read " + ch.getUuid() + " " + value);
		if (ch.getUuid().equals(LBS_BUTTON_CHAR)) {
			button = value[0];
		}
	}

	function setButtonNotifications(value) {
		var service;
		var ch;
		var desc;

		if (device == null) {
			debug("setButtonNotifications: not connected");
			return;
		}
		debug("setButtonNotifications: " + value);

		service = device.getService(LBS_SERVICE);
		ch = service.getCharacteristic(LBS_BUTTON_CHAR);
		desc = ch.getDescriptor(LBS_BUTTON_DESC);
		desc.requestWrite([value & 0x01, 0x00]b);
	}

	function onProfileRegister(uuid, status) {
		debug("registered: " + uuid + " " + status);
	}

	function registerProfiles() {
		var profile = {
			:uuid => LBS_SERVICE,
			:characteristics => [{
				:uuid => LBS_LED_CHAR,
                        }, {
				:uuid => LBS_BUTTON_CHAR,
				:descriptors => [LBS_BUTTON_DESC],
			}]
		};

		BluetoothLowEnergy.registerProfile(profile);
	}

	function onScanStateChange(scanState, status) {
		debug("scanstate: " + scanState + " " + status);
		if (scanState == Ble.SCAN_STATE_SCANNING) {
			scanning = true;
		} else {
			scanning = false;
		}
	}

	function onConnectedStateChanged(device, state) {
		debug("connected: " + device.getName() + " " + state);
		if (state == Ble.CONNECTION_STATE_CONNECTED) {
			self.device = device;
			setButtonNotifications(1);
		} else {
			self.device = null;
		}
	}

	private function connect(result) {
		debug("connect");
		Ble.setScanState(Ble.SCAN_STATE_OFF);
		Ble.pairDevice(result);
	}

	private function dumpUuids(iter) {
		for (var x = iter.next(); x != null; x = iter.next()) {
			debug("uuid: " + x);
		}
	}

	private function dumpMfg(iter) {
		for (var x = iter.next(); x != null; x = iter.next()) {
			debug("mfg: companyId: " + x.get(:companyId) + " data: " + x.get(:data));
		}
	}

	function onScanResults(scanResults) {
		debug("scan results");
		var appearance, name, rssi;
		var mfg, uuids, service;
		for (var result = scanResults.next(); result != null; result = scanResults.next()) {
			appearance = result.getAppearance();
			name = result.getDeviceName();
			rssi = result.getRssi();
			mfg = result.getManufacturerSpecificDataIterator();
			uuids = result.getServiceUuids();

			debug("device: appearance: " + appearance + " name: " + name + " rssi: " + rssi);
			dumpUuids(uuids);
			dumpMfg(mfg);

			if (name != null && name.equals(DEVICE_NAME)) {
				connect(result);
				return;
			}
		}
	}

	function open() {
		registerProfiles();
	}

	function scan() {
		if (scan_delay == 0) {
			return;
		}

		debug(scan_delay);

		scan_delay--;
		if (scan_delay) {
			return;
		}

		debug("scan on");
		Ble.setScanState(Ble.SCAN_STATE_SCANNING);
	}

	function close() {
		debug("close");
		if (scanning) {
			Ble.setScanState(Ble.SCAN_STATE_OFF);
		}
		if (device != null) {
			Ble.unpairDevice(device);
		}
	}
}
