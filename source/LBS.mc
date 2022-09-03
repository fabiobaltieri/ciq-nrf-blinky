// vim: syntax=c

using Toybox.BluetoothLowEnergy as Ble;

class LBS extends BleDevice {
	private const DEVICE_NAME = "Nordic_Blinky";
	private const DEVICE_NAME_Z = "Nordic_LBS";
	protected const SERVICE = Ble.stringToUuid("00001523-1212-efde-1523-785feabcd123");
	protected const READ_CHAR = Ble.stringToUuid("00001524-1212-efde-1523-785feabcd123");
	protected const READ_DESC = Ble.cccdUuid();
	protected const WRITE_CHAR = Ble.stringToUuid("00001525-1212-efde-1523-785feabcd123");

	protected const SCAN_TIMEOUT = 5;
	protected const RESCAN_DELAY = 10;

	var button = 0;

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

	protected function matchDevice(name, mfg, uuids) {
		dumpUuids(uuids);
		dumpMfg(mfg);

		if (name != null && (
			name.equals(DEVICE_NAME) ||
			name.equals(DEVICE_NAME_Z))) {
			return true;
		}

		return false;
	}

	function setLed(value) {
		write([value & 0xff]b);
	}

	protected function read(value) {
		button = value[0];
	}

	protected function reset() {
		button = 0;
	}
}
