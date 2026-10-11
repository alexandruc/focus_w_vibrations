import Toybox.Test;
import Toybox.Lang;

(:test)
function testFocusClockCountsRunningTime(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    return clock.elapsedAt(6000) == 5000;
}

(:test)
function testFocusClockFreezesWhenPaused(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(41000);
    return clock.elapsedAt(90000) == 40000;
}

(:test)
function testFocusClockExcludesPauseWhenResumed(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(41000);
    clock.resume(1041000);
    return clock.elapsedAt(1051000) == 50000;
}

(:test)
function testFocusClockDoesNotAlertBeforeFiveMinutes(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(0);
    return !clock.consumeAlert(299999);
}

(:test)
function testFocusClockAlertsOnceAtFiveMinutes(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(0);
    if (!clock.consumeAlert(300000)) { return false; }
    return !clock.consumeAlert(300000);
}

(:test)
function testFocusClockResetClearsElapsedTime(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(6000);
    clock.reset();
    return clock.elapsedAt(8000) == 0 && !clock.consumeAlert(8000);
}
