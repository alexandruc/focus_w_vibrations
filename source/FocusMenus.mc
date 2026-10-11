import Toybox.Lang;
import Toybox.WatchUi;

module FocusMenus {
    function pausedLabels() as Array<String> {
        return ["Resume", "Save", "Discard"];
    }

    function showPausedMenu(session as FocusSession) as Void {
        var labels = pausedLabels();
        var menu = new WatchUi.Menu();
        menu.setTitle("Paused");
        menu.addItem(labels[0], :resume);
        menu.addItem(labels[1], :save);
        menu.addItem(labels[2], :discard);
        WatchUi.pushView(menu, new FocusMenuDelegate(session), WatchUi.SLIDE_UP);
    }
}
