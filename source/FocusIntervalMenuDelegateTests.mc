import Toybox.Test;
import Toybox.Lang;

(:test)
function testIntervalMenuIncreaseActionUpdatesSettings(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    var delegate = new FocusIntervalMenuDelegate(session);
    return delegate.applyAction(:increase) && session.vibrationIntervalLabel().equals("6 min");
}

(:test)
function testIntervalMenuRandomActionUpdatesSettings(logger as Test.Logger) as Boolean {
    var session = new FocusSession();
    var delegate = new FocusIntervalMenuDelegate(session);
    return delegate.applyAction(:random) && session.vibrationIntervalLabel().equals("Random 1-5 min");
}
