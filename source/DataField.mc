// vim: syntax=c

using Toybox.WatchUi;
using Toybox.System;

class DataField extends WatchUi.SimpleDataField {
	function initialize() {
		SimpleDataField.initialize();
		label = "nRF Blinky";
	}

	function compute(info) {
		return "0 off";
	}
}
