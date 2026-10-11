import Toybox.Test;
import Toybox.Lang;

(:test)
function testIntervalDefaultsToFiveFixedMinutes(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    return settings.minutes() == 5 &&
           !settings.isRandom() &&
           settings.intervalMs(0) == 300000 &&
           settings.label().equals("5 min");
}

(:test)
function testRandomModeSelectsOneToFiveMinuteIntervals(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    settings.enableRandom();
    return settings.isRandom() &&
           settings.intervalMs(0) == 60000 &&
           settings.intervalMs(1) == 120000 &&
           settings.intervalMs(4) == 300000 &&
           settings.intervalMs(5) == 60000 &&
           settings.label().equals("Random 1-5 min");
}

(:test)
function testFixedIntervalAdjustsByOneMinuteWithinBounds(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    var steps = 0;
    while (steps < 10) {
        settings.decrease();
        steps += 1;
    }
    if (settings.minutes() != 1) { return false; }
    steps = 0;
    while (steps < 100) {
        settings.increase();
        steps += 1;
    }
    return settings.minutes() == 60;
}

(:test)
function testIncrementAndDecrementSwitchRandomModeToFixed(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    settings.enableRandom();
    settings.increase();
    return !settings.isRandom() && settings.minutes() == 6 && settings.intervalMs(0) == 360000;
}
