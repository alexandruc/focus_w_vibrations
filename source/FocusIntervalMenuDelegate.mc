import Toybox.Lang;
import Toybox.WatchUi;

class FocusIntervalMenuDelegate extends WatchUi.MenuInputDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        MenuInputDelegate.initialize();
        mSession = session;
    }

    function applyAction(item as Symbol) as Boolean {
        if (item == :decrease) {
            mSession.decreaseVibrationInterval();
            return true;
        }
        if (item == :increase) {
            mSession.increaseVibrationInterval();
            return true;
        }
        if (item == :random) {
            mSession.setRandomVibrationInterval();
            return true;
        }
        return false;
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :done) {
            mSession.closeVibrationSettingsMenu();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (applyAction(item)) {
            FocusMenus.refreshVibrationSettingsMenu(mSession);
        }
    }

    function onBack() as Boolean {
        mSession.closeVibrationSettingsMenu();
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
