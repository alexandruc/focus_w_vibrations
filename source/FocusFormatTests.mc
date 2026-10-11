import Toybox.Test;
import Toybox.Lang;

(:test)
function testElapsedTimerFormatting(logger as Test.Logger) as Boolean {
    var zero = FocusFormat.elapsedLabel(0);
    var seconds = FocusFormat.elapsedLabel(59000);
    var minute = FocusFormat.elapsedLabel(60000);
    var hour = FocusFormat.elapsedLabel(3600000);
    return zero.equals("00:00:00") &&
           seconds.equals("00:00:59") &&
           minute.equals("00:01:00") &&
           hour.equals("01:00:00");
}

(:test)
function testClockFormattingFollows24HourSetting(logger as Test.Logger) as Boolean {
    return FocusFormat.timeOfDayLabel(0, 7, true).equals("00:07") &&
           FocusFormat.timeOfDayLabel(13, 5, true).equals("13:05");
}

(:test)
function testClockFormattingFollows12HourSetting(logger as Test.Logger) as Boolean {
    return FocusFormat.timeOfDayLabel(0, 7, false).equals("12:07 AM") &&
           FocusFormat.timeOfDayLabel(12, 0, false).equals("12:00 PM") &&
           FocusFormat.timeOfDayLabel(13, 5, false).equals("1:05 PM");
}
