// vim: syntax=c

using Toybox.Application;
using Toybox.BluetoothLowEnergy as Ble;

class Main extends Application.AppBase {
	private var bleDevice;

	function initialize() {
		AppBase.initialize();
	}

	function onStart(state) {
		bleDevice = new LBS();
		Ble.setDelegate(bleDevice);
		bleDevice.open();
	}

	function getInitialView() {
		return [new DataField(bleDevice)];
	}

	function onStop(state) {
		bleDevice.close();
	}
}
