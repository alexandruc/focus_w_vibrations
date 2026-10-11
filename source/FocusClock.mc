import Toybox.Lang;
using Toybox.Math;

class FocusClock {
    var mAccumulatedMs = 0;
    var mSegmentStartMs = 0;
    var mNextAlertMs = 300000;
    var mRunning = false;
    var mStarted = false;

    function initialize() {
        reset();
    }

    function start(nowMs as Number) as Void {
        mAccumulatedMs = 0;
        mSegmentStartMs = nowMs;
        mNextAlertMs = 300000;
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

    function consumeAlert(nowMs as Number) as Boolean {
        if (!mRunning) {
            return false;
        }
        var elapsed = elapsedAt(nowMs);
        if (elapsed < mNextAlertMs) {
            return false;
        }
        mNextAlertMs = (Math.floor(elapsed / 300000) + 1) * 300000;
        return true;
    }

    function reset() as Void {
        mAccumulatedMs = 0;
        mSegmentStartMs = 0;
        mNextAlertMs = 300000;
        mRunning = false;
        mStarted = false;
    }
}
