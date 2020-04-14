// vim: syntax=c

using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;

class Main extends Application.AppBase {
	hidden var bleDevice;

	function initialize() {
		AppBase.initialize();
	}

	function onStart(state) {
		bleDevice = new BleDevice();
		Ble.setDelegate(bleDevice);
		bleDevice.open();
		return false;
	}

	function getInitialView() {
		return [new DataField(bleDevice)];
	}

	function onStop(state) {
		bleDevice.close();
		return false;
	}
}
