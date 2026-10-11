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
        if (mSession.isPaused()) {
            mSession.showPausedMenuWhenReady();
        }
        return true;
    }

    function onKeyPressed(keyEvent as WatchUi.KeyEvent) as Boolean {
        if (keyEvent.getKey() == WatchUi.KEY_UP) {
            if (mUpPressStartedAt == null) {
                mUpPressStartedAt = System.getTimer();
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
            if (FocusLongPress.isSettingsHold(heldMs)) {
                mSession.showVibrationSettingsMenuWhenReady();
            }
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
