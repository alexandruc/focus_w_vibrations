import Toybox.Test;
import Toybox.Lang;

(:test)
function testManualIntervalButtonsAdjustCounterByOne(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    var counter = new FocusMinuteCounter(5);
    var delegate = new FocusManualIntervalDelegate(session, counter);
    if (!delegate.adjustForButton(:up) || counter.value() != 6) { return false; }
    if (!delegate.adjustForButton(:down) || counter.value() != 5) { return false; }
    return !delegate.adjustForButton(:select);
}

(:test)
function testManualIntervalSelectionSavesValue(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    var counter = new FocusMinuteCounter(7);
    var delegate = new FocusManualIntervalDelegate(session, counter);
    delegate.saveSelection();
    return session.vibrationIntervalLabel().equals("Manual 7 min");
}
