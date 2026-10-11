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
        } else if (item == :save) {
            mSession.finish();
        } else if (item == :discard) {
            mSession.discard();
        }
        WatchUi.requestUpdate();
    }
}
