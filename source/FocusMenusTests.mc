import Toybox.Test;
import Toybox.Lang;

(:test)
function testPausedMenuUsesSystemMenuResource(logger as Test.Logger) as Boolean {
    var menu = FocusMenus.createPausedMenu();
    return menu != null;
}

(:test)
function testIntervalModeMenuCreatesSystemMenu(logger as Test.Logger) as Boolean {
    return FocusMenus.createIntervalModeMenu(true) != null;
}

(:test)
function testIntervalModeOrderStartsWithSavedChoice(logger as Test.Logger) as Boolean {
    var autoOrder = FocusMenus.intervalModeOrder(true);
    var manualOrder = FocusMenus.intervalModeOrder(false);
    return autoOrder[0] == :auto && autoOrder[1] == :manual &&
           manualOrder[0] == :manual && manualOrder[1] == :auto;
}
