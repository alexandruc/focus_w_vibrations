import Toybox.Test;
import Toybox.Lang;

(:test)
function testIntervalDefaultsToAutoRandomOneThroughTenMinutes(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    return settings.isAuto() &&
           settings.intervalMs(0) == 60000 &&
           settings.intervalMs(9) == 600000 &&
           settings.intervalMs(10) == 60000 &&
           settings.label().equals("Auto 1-10 min");
}

(:test)
function testManualModeUsesSelectedFixedInterval(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    settings.setManualMinutes(7);
    return !settings.isAuto() &&
           settings.intervalMs(0) == 420000 &&
           settings.intervalMs(9) == 420000 &&
           settings.label().equals("Manual 7 min");
}

(:test)
function testManualIntervalClampsToOneThroughSixtyMinutes(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    settings.setManualMinutes(0);
    if (settings.minutes() != 1) { return false; }
    settings.setManualMinutes(61);
    return settings.minutes() == 60;
}

(:test)
function testAutoCanBeSelectedAfterManualMode(logger as Test.Logger) as Boolean {
    var settings = new FocusIntervalSettings();
    settings.setManualMinutes(8);
    settings.useAuto();
    return settings.isAuto() &&
           settings.minutes() == 8 &&
           settings.label().equals("Auto 1-10 min");
}
