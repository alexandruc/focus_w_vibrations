import Toybox.Lang;
import Toybox.WatchUi;

module FocusMenus {
    function createPausedMenu() as WatchUi.Menu {
        var menu = new Rez.Menus.PausedMenu();
        menu.setTitle("Paused");
        return menu;
    }

    function showPausedMenu(session as FocusSession) as Void {
        WatchUi.pushView(createPausedMenu(), new FocusMenuDelegate(session), WatchUi.SLIDE_UP);
    }

    function createVibrationSettingsMenu(session as FocusSession) as WatchUi.Menu {
        var menu = new WatchUi.Menu();
        menu.setTitle("Interval: " + session.vibrationIntervalLabel());
        menu.addItem("Decrease 1 min", :decrease);
        menu.addItem("Increase 1 min", :increase);
        menu.addItem("Random 1-5 min", :random);
        menu.addItem("Done", :done);
        return menu;
    }

    function showVibrationSettingsMenu(session as FocusSession) as Void {
        WatchUi.pushView(createVibrationSettingsMenu(session), new FocusIntervalMenuDelegate(session), WatchUi.SLIDE_UP);
    }

    function refreshVibrationSettingsMenu(session as FocusSession) as Void {
        WatchUi.switchToView(createVibrationSettingsMenu(session), new FocusIntervalMenuDelegate(session), WatchUi.SLIDE_UP);
    }
}
