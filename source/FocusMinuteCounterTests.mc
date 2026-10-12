import Toybox.Test;
import Toybox.Lang;

(:test)
function testManualCounterChangesByOneMinute(logger as Test.Logger) as Boolean {
    var counter = new FocusMinuteCounter(5);
    counter.increase();
    if (counter.value() != 6) { return false; }
    counter.decrease();
    return counter.value() == 5;
}

(:test)
function testManualCounterClampsToOneThroughSixtyMinutes(logger as Test.Logger) as Boolean {
    var low = new FocusMinuteCounter(0);
    low.decrease();
    var high = new FocusMinuteCounter(61);
    high.increase();
    return low.value() == 1 && high.value() == 60;
}
