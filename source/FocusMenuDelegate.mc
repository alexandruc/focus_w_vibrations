import Toybox.Lang;
import Toybox.WatchUi;

class FocusMenuDelegate extends WatchUi.MenuInputDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        MenuInputDelegate.initialize();
        mSession = session;
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :resume) {
            mSession.resume();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (item == :save) {
            mSession.finish();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        } else if (item == :discard) {
            mSession.discard();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
        WatchUi.requestUpdate();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
