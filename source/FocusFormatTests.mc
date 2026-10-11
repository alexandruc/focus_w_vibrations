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
