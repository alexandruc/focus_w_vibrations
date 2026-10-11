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
