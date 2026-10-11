import Toybox.Lang;

class FocusPopup {
    private var mEndMs = 0;
    private var mActive = false;

    function initialize() {
        clear();
    }

    function begin(startMs as Number, durationMs as Number) as Void {
        mEndMs = startMs + durationMs;
        mActive = durationMs > 0;
    }

    function isVisible(nowMs as Number) as Boolean {
        if (!mActive) {
            return false;
        }
        if (nowMs >= mEndMs) {
            mActive = false;
            return false;
        }
        return true;
    }

    function clear() as Void {
        mEndMs = 0;
        mActive = false;
    }
}
