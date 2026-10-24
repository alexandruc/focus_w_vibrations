import Toybox.Test;
import Toybox.Lang;
import Toybox.Application;

(:test)
function testFocusSessionStartsPausesResumesAndSaves(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    if (!session.start()) {
        return false;
    }
    if (!session.pause()) {
        session.discard();
        return false;
    }
    if (!session.resume()) {
        session.discard();
        return false;
    }
    return session.finish();
}

(:test)
function testStartButtonStartsThenPauses(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    if (!session.startButton()) {
        return false;
    }
    if (!session.isRecording()) {
        session.discard();
        return false;
    }
    if (!session.startButton()) {
        session.discard();
        return false;
    }
    var paused = session.isPaused();
    var discarded = session.discard();
    return paused && discarded;
}

(:test)
function testFocusSessionCanDiscard(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    if (!session.start()) {
        return false;
    }
    return session.discard();
}

(:test)
function testFocusSessionCanChooseAutoOrManualVibrationInterval(logger as Test.Logger) as Boolean {
    Application.Storage.deleteValue("focus_interval_mode");
    Application.Storage.deleteValue("focus_interval_minutes");
    var session = new FocusSession();
    if (!session.vibrationIntervalLabel().equals("Auto 1-10 min")) { return false; }
    session.setManualVibrationInterval(7);
    if (!session.vibrationIntervalLabel().equals("Manual 7 min")) { return false; }
    session.setAutoVibrationInterval();
    return session.vibrationIntervalLabel().equals("Auto 1-10 min") &&
           session.manualVibrationMinutes() == 7;
}

(:test)
function testVibrationChoicePersistsAcrossSessionRecreation(logger as Test.Logger) as Boolean {
    var modeKey = "focus_interval_mode";
    var minutesKey = "focus_interval_minutes";
    Application.Storage.deleteValue(modeKey);
    Application.Storage.deleteValue(minutesKey);

    var first = new FocusSession();
    first.setManualVibrationInterval(7);
    var second = new FocusSession();
    var manualRestored = second.vibrationIntervalLabel().equals("Manual 7 min");
    second.setAutoVibrationInterval();
    var third = new FocusSession();
    var autoRestored = third.vibrationIntervalLabel().equals("Auto 1-10 min") &&
                       third.manualVibrationMinutes() == 7;

    Application.Storage.deleteValue(modeKey);
    Application.Storage.deleteValue(minutesKey);
    return manualRestored && autoRestored;
}
