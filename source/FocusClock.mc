import Toybox.Lang;

class FocusClock {
    var mAccumulatedMs = 0;
    var mSegmentStartMs = 0;
    var mNextAlertMs = 300000;
    var mIntervalMs = 300000;
    var mRunning = false;
    var mStarted = false;

    function initialize() {
        reset();
    }

    function start(nowMs as Number) as Void {
        mAccumulatedMs = 0;
        mSegmentStartMs = nowMs;
        mIntervalMs = 300000;
        mNextAlertMs = mIntervalMs;
        mRunning = true;
        mStarted = true;
    }

    function pause(nowMs as Number) as Void {
        if (mRunning) {
            mAccumulatedMs += nowMs - mSegmentStartMs;
            mRunning = false;
        }
    }

    function resume(nowMs as Number) as Void {
        if (mStarted && !mRunning) {
            mSegmentStartMs = nowMs;
            mRunning = true;
        }
    }

    function elapsedAt(nowMs as Number) as Number {
        if (!mStarted) {
            return 0;
        }
        if (!mRunning) {
            return mAccumulatedMs;
        }
        return mAccumulatedMs + nowMs - mSegmentStartMs;
    }

    function setNextInterval(nowMs as Number, intervalMs as Number) as Void {
        mIntervalMs = intervalMs;
        mNextAlertMs = elapsedAt(nowMs) + intervalMs;
    }

    function consumeAlert(nowMs as Number) as Boolean {
        if (!mRunning) {
            return false;
        }
        var elapsed = elapsedAt(nowMs);
        if (elapsed < mNextAlertMs) {
            return false;
        }
        mNextAlertMs = elapsed + mIntervalMs;
        return true;
    }

    function reset() as Void {
        mAccumulatedMs = 0;
        mSegmentStartMs = 0;
        mIntervalMs = 300000;
        mNextAlertMs = mIntervalMs;
        mRunning = false;
        mStarted = false;
    }
}
