import Toybox.Test;
import Toybox.Lang;

(:test)
function testFocusPopupStaysVisibleUntilVibrationEnd(logger as Test.Logger) as Boolean {
    var popup = new FocusPopup();
    popup.begin(1000, 1500);
    return popup.isVisible(1000) &&
           popup.isVisible(2499) &&
           !popup.isVisible(2500);
}

(:test)
function testFocusPopupCanBeCleared(logger as Test.Logger) as Boolean {
    var popup = new FocusPopup();
    popup.begin(500, 3000);
    popup.clear();
    return !popup.isVisible(600);
}
