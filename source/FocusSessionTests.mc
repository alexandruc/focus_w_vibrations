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
function testFocusSessionCanDiscard(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    if (!session.start()) {
        return false;
    }
    return session.discard();
}
