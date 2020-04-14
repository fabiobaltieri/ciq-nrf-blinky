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
		return "0 off";
	}
}
