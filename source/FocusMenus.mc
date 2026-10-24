import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

module FocusMenus {
    function intervalModeOrder(isAuto as Boolean) as Array<Symbol> {
        if (isAuto) {
            return [:auto, :manual];
        }
        return [:manual, :auto];
    }

    function createPausedMenu() as WatchUi.Menu {
        var menu = new Rez.Menus.PausedMenu();
        menu.setTitle("Paused");
        return menu;
    }

    function showPausedMenu(session as FocusSession) as Void {
        WatchUi.pushView(createPausedMenu(), new FocusMenuDelegate(session), WatchUi.SLIDE_UP);
    }

    function createIntervalModeMenu(isAuto as Boolean) as WatchUi.Menu {
        var menu = new WatchUi.Menu();
        menu.setTitle("Vibration interval");
        var order = intervalModeOrder(isAuto);
        if (order[0] == :auto) {
            menu.addItem(Rez.Strings.IntervalAuto, :auto);
            menu.addItem(Rez.Strings.IntervalManual, :manual);
        } else {
            menu.addItem(Rez.Strings.IntervalManual, :manual);
            menu.addItem(Rez.Strings.IntervalAuto, :auto);
        }
        return menu;
    }

    function showIntervalModeMenu(session as FocusSession) as Void {
        System.println("[AUTO-TRACE] FocusMenus.push interval menu begin");
        WatchUi.pushView(createIntervalModeMenu(session.isAutoVibrationInterval()), new FocusIntervalMenuDelegate(session), WatchUi.SLIDE_UP);
        System.println("[AUTO-TRACE] FocusMenus.push interval menu returned");
    }
}
