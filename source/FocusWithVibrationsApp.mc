import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class FocusWithVibrationsApp extends Application.AppBase {
    private var mSession as FocusSession;

    function initialize() {
        AppBase.initialize();
        mSession = new FocusSession();
    }

    function onStart(state as Dictionary?) as Void {
    }

    function onStop(state as Dictionary?) as Void {
        if (mSession != null && mSession.hasOpenSession()) {
            mSession.finish();
        }
    }

    function getInitialView() as [Views] or [Views, InputDelegates] {
        var view = new FocusWithVibrationsView(mSession);
        return [view, new FocusWithVibrationsDelegate(mSession)];
    }
}

function getApp() as FocusWithVibrationsApp {
    return Application.getApp() as FocusWithVibrationsApp;
}
