import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FocusWithVibrationsDelegate extends WatchUi.BehaviorDelegate {
    private var mSession as FocusSession;
    private var mUpPressStartedAt as Number?;

    function initialize(session as FocusSession) {
        BehaviorDelegate.initialize();
        mSession = session;
        mUpPressStartedAt = null;
    }

    function onSelect() as Boolean {
        if (mSession.isReady()) {
            return mSession.startButton();
        }
        if (mSession.isRecording()) {
            if (!mSession.startButton()) {
                return false;
            }
            mSession.showPausedMenuWhenReady();
            return true;
        }
        if (mSession.isPaused()) {
            mSession.showPausedMenuWhenReady();
        }
        return true;
    }

    function onMenu() as Boolean {
        System.println("[AUTO-TRACE] delegate.onMenu entered");
        mSession.showIntervalModeMenuWhenReady();
        System.println("[AUTO-TRACE] delegate.onMenu returned");
        return true;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            if (mUpPressStartedAt == null) {
                mUpPressStartedAt = System.getTimer();
                System.println("[AUTO-TRACE] UP key pressed; hold timer started");
            }
            return true;
        }
        return false;
    }

    function onKeyReleased(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() != WatchUi.KEY_UP) {
            return false;
        }
        if (mUpPressStartedAt != null) {
            var heldMs = System.getTimer() - mUpPressStartedAt;
            mUpPressStartedAt = null;
            System.println("[AUTO-TRACE] UP key released; held_ms=" + heldMs.toString());
            if (FocusLongPress.isMenuHold(heldMs)) {
                System.println("[AUTO-TRACE] UP hold met menu threshold");
                return onMenu();
            }
            System.println("[AUTO-TRACE] UP hold below menu threshold");
        }
        return true;
    }

    function onBack() as Boolean {
        if (mSession.hasOpenSession()) {
            return true;
        }
        return false;
    }
}
