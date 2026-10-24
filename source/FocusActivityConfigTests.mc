import Toybox.Test;
import Toybox.Lang;

(:test)
function testFocusActivityUsesGenericSportAndShortName(logger as Test.Logger) as Boolean {
    var options = FocusActivityConfig.options();
    return options[:name].equals("Focus") &&
           options[:sport] == 0 &&
           options[:subSport] == 0;
}
