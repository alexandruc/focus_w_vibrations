import Toybox.Lang;

class FocusMinuteCounter {
    const MIN_MINUTES = 1;
    const MAX_MINUTES = 60;

    private var mMinutes as Number;

    function initialize(initialMinutes as Number) {
        if (initialMinutes < MIN_MINUTES) {
            mMinutes = MIN_MINUTES;
        } else if (initialMinutes > MAX_MINUTES) {
            mMinutes = MAX_MINUTES;
        } else {
            mMinutes = initialMinutes;
        }
    }

    function value() as Number {
        return mMinutes;
    }

    function increase() as Void {
        if (mMinutes < MAX_MINUTES) {
            mMinutes += 1;
        }
    }

    function decrease() as Void {
        if (mMinutes > MIN_MINUTES) {
            mMinutes -= 1;
        }
    }
}
