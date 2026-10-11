import Toybox.Test;
import Toybox.Lang;

(:test)
function testPausedMenuUsesSystemMenuResource(logger as Test.Logger) as Boolean {
    var menu = FocusMenus.createPausedMenu();
    return menu != null;
}
