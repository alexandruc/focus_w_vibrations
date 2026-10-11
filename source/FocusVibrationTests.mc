import Toybox.Test;
import Toybox.Lang;

(:test)
function testFocusPulseDurationsStayWithinThreeSeconds(logger as Test.Logger) as Boolean {
    for (var i = 0; i < FocusVibration.PATTERN_COUNT; i += 1) {
        var duration = FocusVibration.pulseLengthForIndex(i);
        if (duration <= 0 || duration > FocusVibration.MAX_TOTAL_MS) {
            return false;
        }
    }
    return true;
}

(:test)
function testRandomValueMapsToValidPulseIndex(logger as Test.Logger) as Boolean {
    for (var value = 0; value < 100; value += 1) {
        var index = FocusVibration.indexForRandomValue(value);
        if (index < 0 || index >= FocusVibration.PATTERN_COUNT) {
            return false;
        }
    }
    return true;
}

(:test)
function testFocusPulseProfileIsSingleVibration(logger as Test.Logger) as Boolean {
    for (var i = 0; i < FocusVibration.PATTERN_COUNT; i += 1) {
        var profile = FocusVibration.profileForIndex(i);
        if (profile.length <= 0 || profile.length > 3000) {
            return false;
        }
    }
    return true;
}
