import Toybox.Lang;
import Toybox.WatchUi;

class FocusWithVibrationsDelegate extends WatchUi.BehaviorDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        BehaviorDelegate.initialize();
        mSession = session;
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

    function onBack() as Boolean {
        if (mSession.hasOpenSession()) {
            return true;
        }
        return false;
    }
}
