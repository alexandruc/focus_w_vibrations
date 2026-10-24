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
function testFocusPopupCanDisplayCustomText(logger as Test.Logger) as Boolean {
    var popup = new FocusPopup();
    popup.beginMessage(1000, 2000, "Random value up to 10 min");
    return popup.message().equals("Random value up to 10 min") && popup.isVisible(1000);
}

(:test)
function testAutoPopupSplitsMessageIntoTwoRows(logger as Test.Logger) as Boolean {
    var popup = new FocusPopup();
    popup.beginMessage(1000, 2000, "Random value up to 10 min");
    var lines = popup.displayLines();
    return lines.size() == 2 &&
           lines[0].equals("Random value up to") &&
           lines[1].equals("10 min");
}

(:test)
function testFocusPopupCanBeCleared(logger as Test.Logger) as Boolean {
    var popup = new FocusPopup();
    popup.begin(500, 3000);
    popup.clear();
    return !popup.isVisible(600);
}
