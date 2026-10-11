import Toybox.Test;
import Toybox.Lang;
import Toybox.Activity;

(:test)
function testFocusActivityUsesGenericSportAndShortName(logger as Test.Logger) as Boolean {
    var options = FocusActivityConfig.options();
    return options[:name].equals("Focus") &&
           options[:sport] == Activity.SPORT_GENERIC &&
           options[:subSport] == Activity.SUB_SPORT_GENERIC;
}
