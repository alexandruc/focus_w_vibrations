import Toybox.Test;
import Toybox.Lang;

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
function testFocusSessionCanConfigureVibrationInterval(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    if (!session.vibrationIntervalLabel().equals("5 min")) { return false; }
    session.increaseVibrationInterval();
    if (!session.vibrationIntervalLabel().equals("6 min")) { return false; }
    session.decreaseVibrationInterval();
    if (!session.vibrationIntervalLabel().equals("5 min")) { return false; }
    session.setRandomVibrationInterval();
    return session.vibrationIntervalLabel().equals("Random 1-5 min");
}
