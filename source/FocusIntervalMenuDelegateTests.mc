import Toybox.Test;
import Toybox.Lang;

(:test)
function testAutoMenuActionSetsRandomOneToTenMinuteMode(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    session.setManualVibrationInterval(7);
    var delegate = new FocusIntervalMenuDelegate(session);
    return delegate.applyAction(:auto) &&
           session.vibrationIntervalLabel().equals("Auto 1-10 min") &&
           session.manualVibrationMinutes() == 7;
}

(:test)
function testManualMenuActionIsRecognized(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    var delegate = new FocusIntervalMenuDelegate(session);
    return delegate.isManualAction(:manual) && !delegate.isManualAction(:auto);
}
