// vim: syntax=c

using Toybox.System;
using Toybox.BluetoothLowEnergy as Ble;

class BleDevice extends Ble.BleDelegate {
	var scanning = false;
	var paired = false;
	var device = null;
	private var scan_delay = 5;
	private var scan_timeout;

	protected function debug(str) {
		System.println("[ble] " + str);
	}

	function initialize() {
		BleDelegate.initialize();
		debug("initialize");
	}

	protected function write(data) {
		var service;
		var ch;

		if (device == null) {
			debug("write: not connected");
			return;
		}
		debug("write: " + data);

		service = device.getService(SERVICE);
		ch = service.getCharacteristic(WRITE_CHAR);
		try {
			ch.requestWrite(data, {:writeType => Ble.WRITE_TYPE_DEFAULT});
		} catch (ex) {
			debug("write: can't start char write");
		}
	}

	function onCharacteristicChanged(ch, value) {
		debug("char read " + ch.getUuid() + " " + value);
		if (ch.getUuid().equals(READ_CHAR)) {
			read(value);
		}
	}

	private function setReadNotifications(value) {
		var service;
		var ch;
		var desc;

		if (device == null) {
			debug("setReadNotifications: not connected");
			return;
		}
		debug("setReadNotifications: " + value);

		service = device.getService(SERVICE);
		ch = service.getCharacteristic(READ_CHAR);
		desc = ch.getDescriptor(READ_DESC);
		desc.requestWrite([value & 0x01, 0x00]b);
	}

	function onProfileRegister(uuid, status) {
		debug("registered: " + uuid + " " + status);
	}

	private function registerProfiles() {
		var profile = {
			:uuid => SERVICE,
			:characteristics => [{
				:uuid => READ_CHAR,
				:descriptors => [READ_DESC],
			}, {
				:uuid => WRITE_CHAR,
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
			setReadNotifications(1);
		} else {
			self.device = null;
			reset();
		}
	}

	private function connect(result) {
		debug("connect");
		Ble.setScanState(Ble.SCAN_STATE_OFF);
		Ble.pairDevice(result);
		paired = true;
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

			if (matchDevice(name, mfg, uuids)) {
				connect(result);
				return;
			}
		}
	}

	function open() {
		registerProfiles();
	}

	function scan() {
		if (paired) {
			return;
		}

		debug("scan delay: " + scan_delay + " timeout: " + scan_timeout);

		if (scanning) {
			if (scan_timeout > 0) {
				scan_timeout--;
				return;
			}
			debug("scan timeout");
			Ble.setScanState(Ble.SCAN_STATE_OFF);
			scan_delay = RESCAN_DELAY;
			return;
		}

		if (scan_delay > 0) {
			scan_delay--;
			return;
		}

		debug("scan on");
		Ble.setScanState(Ble.SCAN_STATE_SCANNING);
		scan_timeout = SCAN_TIMEOUT;
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
