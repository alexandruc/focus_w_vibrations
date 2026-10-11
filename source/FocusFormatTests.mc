import Toybox.Test;
import Toybox.Lang;

(:test)
function testElapsedTimerFormatting(logger as Test.Logger) as Boolean {
    return FocusFormat.elapsedLabel(0) == "00:00:00" &&
           FocusFormat.elapsedLabel(59000) == "00:00:59" &&
           FocusFormat.elapsedLabel(60000) == "00:01:00" &&
           FocusFormat.elapsedLabel(3600000) == "01:00:00";
}
