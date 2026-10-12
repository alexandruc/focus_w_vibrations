import Toybox.Lang;
using Toybox.Math;

module FocusFormat {
    function twoDigits(value as Number) as String {
        var text = value.toString();
        if (value < 10) {
            return "0" + text;
        }
        return text;
    }

    function elapsedLabel(elapsedMs as Number) as String {
        var totalSeconds = Math.floor(elapsedMs / 1000);
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds % 3600) / 60);
        var seconds = totalSeconds % 60;
        return twoDigits(hours) + ":" + twoDigits(minutes) + ":" + twoDigits(seconds);
    }

    function timeOfDayLabel(hour as Number, minute as Number, is24Hour as Boolean) as String {
        if (is24Hour) {
            return twoDigits(hour) + ":" + twoDigits(minute);
        }

        var displayHour = hour % 12;
        if (displayHour == 0) {
            displayHour = 12;
        }
        var suffix = "AM";
        if (hour >= 12) {
            suffix = "PM";
        }
        return displayHour.toString() + ":" + twoDigits(minute) + " " + suffix;
    }
}
