import Toybox.Test;
import Toybox.Lang;

(:test)
function testPausedMenuOffersResumeSaveDiscard(logger as Test.Logger) as Boolean {
    var labels = FocusMenus.pausedLabels();
    return labels.size() == 3 &&
           labels[0].equals("Resume") &&
           labels[1].equals("Save") &&
           labels[2].equals("Discard");
}
