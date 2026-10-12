import Toybox.Test;
import Toybox.Lang;

(:test)
function testUpMenuHoldNeedsEightHundredMilliseconds(logger as Test.Logger) as Boolean {
    return !FocusLongPress.isMenuHold(799) &&
           FocusLongPress.isMenuHold(800) &&
           FocusLongPress.isMenuHold(1200);
}
