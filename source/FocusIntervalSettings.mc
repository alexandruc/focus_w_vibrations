import Toybox.Lang;

class FocusIntervalSettings {
    const MIN_MINUTES = 1;
    const MAX_MINUTES = 60;
    const AUTO_MAX_MINUTES = 10;

    private var mMinutes as Number;
    private var mAuto as Boolean;

    function initialize() {
        mMinutes = 5;
        mAuto = true;
    }

    function minutes() as Number {
        return mMinutes;
    }

    function isAuto() as Boolean {
        return mAuto;
    }

    function setManualMinutes(minutes as Number) as Void {
        if (minutes < MIN_MINUTES) {
            mMinutes = MIN_MINUTES;
        } else if (minutes > MAX_MINUTES) {
            mMinutes = MAX_MINUTES;
        } else {
            mMinutes = minutes;
        }
        mAuto = false;
    }

    function useAuto() as Void {
        mAuto = true;
    }

    function intervalMs(randomValue as Number) as Number {
        if (mAuto) {
            return ((randomValue % AUTO_MAX_MINUTES) + 1) * 60000;
        }
        return mMinutes * 60000;
    }

    function label() as String {
        if (mAuto) {
            return "Auto 1-10 min";
        }
        return "Manual " + mMinutes.toString() + " min";
    }
}
