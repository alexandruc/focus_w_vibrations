import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FocusIntervalMenuDelegate extends WatchUi.MenuInputDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        MenuInputDelegate.initialize();
        mSession = session;
    }

    function isManualAction(item as Symbol) as Boolean {
        return item == :manual;
    }

    function applyAction(item as Symbol) as Boolean {
        if (item == :auto) {
            System.println("[AUTO-TRACE] applyAction auto begin");
            mSession.setAutoVibrationInterval();
            System.println("[AUTO-TRACE] applyAction auto session updated");
            mSession.closeIntervalMenu();
            System.println("[AUTO-TRACE] applyAction auto menu state closed");
            mSession.showAutoSelectionPopup();
            System.println("[AUTO-TRACE] applyAction auto confirmation popup queued");
            return true;
        }
        return false;
    }

    function onMenuItem(item as Symbol) as Void {
        System.println("[AUTO-TRACE] onMenuItem callback entered");
        if (applyAction(item)) {
            System.println("[AUTO-TRACE] onMenuItem auto accepted; letting system menu finish transition");
        } else if (isManualAction(item)) {
            System.println("[AUTO-TRACE] onMenuItem manual selected");
            var counter = new FocusMinuteCounter(mSession.manualVibrationMinutes());
            var view = new FocusManualIntervalView(counter);
            var delegate = new FocusManualIntervalDelegate(mSession, counter);
            WatchUi.switchToView(view, delegate, WatchUi.SLIDE_UP);
        } else {
            System.println("[AUTO-TRACE] onMenuItem ignored non-auto/non-manual item");
        }
    }

    function onBack() as Boolean {
        mSession.closeIntervalMenu();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
