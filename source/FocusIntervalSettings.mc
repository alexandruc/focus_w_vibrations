import Toybox.Lang;

class FocusIntervalSettings {
    const MIN_MINUTES = 1;
    const MAX_MINUTES = 60;
    const RANDOM_MAX_MINUTES = 5;

    private var mMinutes as Number;
    private var mRandom as Boolean;

    function initialize() {
        mMinutes = 5;
        mRandom = false;
    }

    function minutes() as Number {
        return mMinutes;
    }

    function isRandom() as Boolean {
        return mRandom;
    }

    function intervalMs(randomValue as Number) as Number {
        var selectedMinutes = mMinutes;
        if (mRandom) {
            selectedMinutes = (randomValue % RANDOM_MAX_MINUTES) + 1;
        }
        return selectedMinutes * 60000;
    }

    function label() as String {
        if (mRandom) {
            return "Random 1-5 min";
        }
        return mMinutes.toString() + " min";
    }

    function increase() as Void {
        if (mMinutes < MAX_MINUTES) {
            mMinutes += 1;
        }
        mRandom = false;
    }

    function decrease() as Void {
        if (mMinutes > MIN_MINUTES) {
            mMinutes -= 1;
        }
        mRandom = false;
    }

    function enableRandom() as Void {
        mRandom = true;
    }
}
