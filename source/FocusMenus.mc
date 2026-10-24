import Toybox.Lang;
import Toybox.System;
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

    function createIntervalModeMenu() as WatchUi.Menu {
        var menu = new Rez.Menus.IntervalModeMenu();
        menu.setTitle("Vibration interval");
        return menu;
    }

    function showIntervalModeMenu(session as FocusSession) as Void {
        System.println("[AUTO-TRACE] FocusMenus.push interval menu begin");
        WatchUi.pushView(createIntervalModeMenu(), new FocusIntervalMenuDelegate(session), WatchUi.SLIDE_UP);
        System.println("[AUTO-TRACE] FocusMenus.push interval menu returned");
    }
}
