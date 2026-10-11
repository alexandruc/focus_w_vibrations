import Toybox.Attention;
import Toybox.Lang;

module FocusVibration {
    const PATTERN_COUNT = 6;
    const MAX_TOTAL_MS = 3000;
    const DUTY_CYCLE = 70;

    function indexForRandomValue(value as Number) as Number {
        return value % PATTERN_COUNT;
    }

    function pulseLengthForIndex(index as Number) as Number {
        switch (index % PATTERN_COUNT) {
        case 0:
            return 500;
        case 1:
            return 1000;
        case 2:
            return 1500;
        case 3:
            return 2000;
        case 4:
            return 2500;
        default:
            return MAX_TOTAL_MS;
        }
    }

    function profileForIndex(index as Number) as Attention.VibeProfile {
        return new Attention.VibeProfile(DUTY_CYCLE, pulseLengthForIndex(index));
    }
}
