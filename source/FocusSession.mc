import Toybox.ActivityRecording;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Math;
import Toybox.Position;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class FocusSession {
    private var mSession as Session?;
    private var mClock as FocusClock;
    private var mTimer as Timer.Timer;
    private var mState as Symbol;
    private var mMessage as String;

    function initialize() {
        mSession = null;
        mClock = new FocusClock();
        mTimer = new Timer.Timer();
        mState = :ready;
        mMessage = "";
    }

    function start() as Boolean {
        if (mSession != null || !(Toybox has :ActivityRecording)) {
            mMessage = "Unable to start";
            WatchUi.requestUpdate();
            return false;
        }

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        mSession = ActivityRecording.createSession(FocusActivityConfig.options());
        if (!mSession.start()) {
            mSession.discard();
            mSession = null;
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            mMessage = "Start failed";
            WatchUi.requestUpdate();
            return false;
        }

        Math.srand(System.getTimer());
        mClock.start(System.getTimer());
        mState = :recording;
        mMessage = "";
        mTimer.start(method(:onTick), 1000, true);
        WatchUi.requestUpdate();
        return true;
    }

    function pause() as Boolean {
        if (mSession == null || mState != :recording) {
            return false;
        }
        if (!mSession.stop()) {
            mMessage = "Pause failed";
            WatchUi.requestUpdate();
            return false;
        }

        mClock.pause(System.getTimer());
        mTimer.stop();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        mState = :paused;
        mMessage = "";
        WatchUi.requestUpdate();
        return true;
    }

    function resume() as Boolean {
        if (mSession == null || mState != :paused) {
            return false;
        }

        Position.enableLocationEvents(Position.LOCATION_CONTINUOUS, method(:onPosition));
        if (!mSession.start()) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            mMessage = "Resume failed";
            WatchUi.requestUpdate();
            return false;
        }

        mClock.resume(System.getTimer());
        mState = :recording;
        mMessage = "";
        mTimer.start(method(:onTick), 1000, true);
        WatchUi.requestUpdate();
        return true;
    }

    function finish() as Boolean {
        if (mSession == null) {
            return false;
        }
        if (mState == :recording) {
            if (!mSession.stop()) {
                mMessage = "Stop failed";
                WatchUi.requestUpdate();
                return false;
            }
            mClock.pause(System.getTimer());
        }

        mTimer.stop();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        if (!mSession.save()) {
            mState = :paused;
            mMessage = "Save failed";
            WatchUi.requestUpdate();
            return false;
        }

        mSession = null;
        mClock.reset();
        mState = :ready;
        mMessage = "";
        WatchUi.requestUpdate();
        return true;
    }

    function discard() as Boolean {
        if (mSession == null) {
            return false;
        }
        if (mState == :recording) {
            if (!mSession.stop()) {
                mMessage = "Stop failed";
                WatchUi.requestUpdate();
                return false;
            }
            mClock.pause(System.getTimer());
        }

        mTimer.stop();
        Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
        if (!mSession.discard()) {
            mState = :paused;
            mMessage = "Discard failed";
            WatchUi.requestUpdate();
            return false;
        }

        mSession = null;
        mClock.reset();
        mState = :ready;
        mMessage = "";
        WatchUi.requestUpdate();
        return true;
    }

    function isReady() as Boolean {
        return mState == :ready;
    }

    function isRecording() as Boolean {
        return mState == :recording;
    }

    function isPaused() as Boolean {
        return mState == :paused;
    }

    function hasOpenSession() as Boolean {
        return mSession != null;
    }

    function elapsedMs() as Number {
        return mClock.elapsedAt(System.getTimer());
    }

    function statusText() as String {
        if (mMessage != "") {
            return mMessage;
        }
        if (mState == :recording) {
            return "Recording";
        }
        if (mState == :paused) {
            return "Paused";
        }
        return "Ready";
    }

    function onPosition(info as Position.Info) as Void {
    }

    function onTick() as Void {
        if (mState != :recording) {
            return;
        }

        var nowMs = System.getTimer();
        if (mClock.consumeAlert(nowMs) && (Attention has :vibrate)) {
            var index = FocusVibration.indexForRandomValue(Math.rand());
            Attention.vibrate([FocusVibration.profileForIndex(index)]);
        }
        WatchUi.requestUpdate();
    }
}
