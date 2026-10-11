import Toybox.Test;
import Toybox.Lang;

(:test)
function testUpHoldNeedsEightHundredMilliseconds(logger as Test.Logger) as Boolean {
    return !FocusLongPress.isSettingsHold(799) &&
           FocusLongPress.isSettingsHold(800) &&
           FocusLongPress.isSettingsHold(1200);
}
