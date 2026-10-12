import Toybox.Lang;
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
            mSession.setAutoVibrationInterval();
            mSession.closeIntervalMenu();
            return true;
        }
        return false;
    }

    function onMenuItem(item as Symbol) as Void {
        if (applyAction(item)) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (isManualAction(item)) {
            var counter = new FocusMinuteCounter(mSession.manualVibrationMinutes());
            var view = new FocusManualIntervalView(counter);
            var delegate = new FocusManualIntervalDelegate(mSession, counter);
            WatchUi.switchToView(view, delegate, WatchUi.SLIDE_UP);
        }
    }

    function onBack() as Boolean {
        mSession.closeIntervalMenu();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
