import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FocusManualIntervalDelegate extends WatchUi.BehaviorDelegate {
    private var mSession as FocusSession;
    private var mCounter as FocusMinuteCounter;

    function initialize(session as FocusSession, counter as FocusMinuteCounter) {
        BehaviorDelegate.initialize();
        mSession = session;
        mCounter = counter;
    }

    function adjustForButton(button as Symbol) as Boolean {
        if (button == :up) {
            mCounter.increase();
            return true;
        }
        if (button == :down) {
            mCounter.decrease();
            return true;
        }
        return false;
    }

    function saveSelection() as Void {
        mSession.setManualVibrationInterval(mCounter.value());
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        var handled = false;
        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            handled = adjustForButton(:up);
        } else if (keyEvent.getKey() == WatchUi.KEY_DOWN) {
            handled = adjustForButton(:down);
        }
        if (handled) {
            WatchUi.requestUpdate();
        }
        return handled;
    }

    function onSelect() as Boolean {
        saveSelection();
        mSession.closeIntervalMenu();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onMenu() as Boolean {
        return true;
    }

    function onBack() as Boolean {
        mSession.closeIntervalMenu();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
