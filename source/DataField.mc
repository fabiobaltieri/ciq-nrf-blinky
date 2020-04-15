// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;

class DataField extends WatchUi.SimpleDataField {
	hidden var bleDevice;

	function initialize(device) {
		SimpleDataField.initialize();
		label = "nRF Blinky";
		bleDevice = device;
	}

	function compute(info) {
		var led;

		if (bleDevice.scanning) {
			return "Scanning...";
		} else if (bleDevice.device == null) {
			return "Disconnected";
		}

		if (info.timerState == Activity.TIMER_STATE_ON) {
			bleDevice.setLed(1);
			led = "on";
		} else {
			bleDevice.setLed(0);
			led = "off";
		}

		return "l:" + led + " b:" + bleDevice.button;
	}
}
