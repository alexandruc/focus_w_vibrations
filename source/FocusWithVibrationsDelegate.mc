import Toybox.Lang;
import Toybox.WatchUi;

class FocusWithVibrationsDelegate extends WatchUi.BehaviorDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        BehaviorDelegate.initialize();
        mSession = session;
    }

    function onMenu() as Boolean {
        var menu = new WatchUi.Menu();
        menu.setTitle("Focus");

        if (mSession.isReady()) {
            menu.addItem("Start Activity", :start);
        } else if (mSession.isRecording()) {
            menu.addItem("Pause", :pause);
            menu.addItem("Save & Finish", :finish);
            menu.addItem("Discard", :discard);
        } else {
            menu.addItem("Resume", :resume);
            menu.addItem("Save & Finish", :finish);
            menu.addItem("Discard", :discard);
        }

        WatchUi.pushView(menu, new FocusMenuDelegate(mSession), WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        if (mSession.hasOpenSession()) {
            return true;
        }
        return false;
    }
}

class FocusMenuDelegate extends WatchUi.MenuInputDelegate {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        MenuInputDelegate.initialize();
        mSession = session;
    }

    function onMenuItem(item as Symbol) as Void {
        if (item == :start) {
            mSession.start();
        } else if (item == :pause) {
            mSession.pause();
        } else if (item == :resume) {
            mSession.resume();
        } else if (item == :finish) {
            mSession.finish();
        } else if (item == :discard) {
            mSession.discard();
        }
        WatchUi.requestUpdate();
    }
}
