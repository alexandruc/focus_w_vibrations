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
    private var mPopup as FocusPopup;
    private var mPopupTimer as Timer.Timer;
    private var mPauseMenuPending as Boolean;
    private var mSettingsMenuPending as Boolean;
    private var mSettingsMenuOpen as Boolean;
    private var mIntervalSettings as FocusIntervalSettings;

    function initialize() {
        mSession = null;
        mClock = new FocusClock();
        mTimer = new Timer.Timer();
        mState = :ready;
        mMessage = "";
        mPopup = new FocusPopup();
        mPopupTimer = new Timer.Timer();
        mPauseMenuPending = false;
        mSettingsMenuPending = false;
        mSettingsMenuOpen = false;
        mIntervalSettings = new FocusIntervalSettings();
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

        var nowMs = System.getTimer();
        Math.srand(nowMs);
        mClock.start(nowMs);
        mClock.setNextInterval(nowMs, mIntervalSettings.intervalMs(Math.rand()));
        mState = :recording;
        mMessage = "";
        mPopup.clear();
        mPauseMenuPending = false;
        mSettingsMenuPending = false;
        mSettingsMenuOpen = false;
        mTimer.start(method(:onTick), 1000, true);
        WatchUi.requestUpdate();
        return true;
    }

    function startButton() as Boolean {
        if (isReady()) {
            return start();
        }
        if (isRecording()) {
            return pause();
        }
        return false;
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

    function popupVisible() as Boolean {
        return mPopup.isVisible(System.getTimer());
    }

    function showPausedMenuWhenReady() as Void {
        if (mState != :paused) {
            return;
        }
        if (popupVisible()) {
            mPauseMenuPending = true;
            return;
        }
        mPauseMenuPending = false;
        FocusMenus.showPausedMenu(self);
    }

    function vibrationIntervalLabel() as String {
        return mIntervalSettings.label();
    }

    function increaseVibrationInterval() as Void {
        mIntervalSettings.increase();
        rescheduleUpcomingInterval();
    }

    function decreaseVibrationInterval() as Void {
        mIntervalSettings.decrease();
        rescheduleUpcomingInterval();
    }

    function setRandomVibrationInterval() as Void {
        mIntervalSettings.enableRandom();
        rescheduleUpcomingInterval();
    }

    function showVibrationSettingsMenuWhenReady() as Void {
        if (popupVisible()) {
            mSettingsMenuPending = true;
            return;
        }
        mSettingsMenuPending = false;
        mSettingsMenuOpen = true;
        FocusMenus.showVibrationSettingsMenu(self);
    }

    function closeVibrationSettingsMenu() as Void {
        mSettingsMenuOpen = false;
        mSettingsMenuPending = false;
    }

    private function rescheduleUpcomingInterval() as Void {
        if (mState == :recording || mState == :paused) {
            var nowMs = System.getTimer();
            mClock.setNextInterval(nowMs, mIntervalSettings.intervalMs(Math.rand()));
        }
        WatchUi.requestUpdate();
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

    function onPopupEnd() as Void {
        mPopup.clear();
        WatchUi.requestUpdate();
        if (mPauseMenuPending && mState == :paused) {
            mPauseMenuPending = false;
            mSettingsMenuPending = false;
            FocusMenus.showPausedMenu(self);
        } else if (mSettingsMenuPending) {
            mSettingsMenuPending = false;
            mSettingsMenuOpen = true;
            FocusMenus.showVibrationSettingsMenu(self);
        }
    }

    function onTick() as Void {
        if (mState != :recording) {
            return;
        }

        var nowMs = System.getTimer();
        if (mClock.consumeAlert(nowMs)) {
            if (Attention has :vibrate) {
                var index = FocusVibration.indexForRandomValue(Math.rand());
                var durationMs = FocusVibration.pulseLengthForIndex(index);
                mPopup.begin(nowMs, durationMs);
                mPopupTimer.start(method(:onPopupEnd), durationMs, false);
                if (mSettingsMenuOpen) {
                    mSettingsMenuOpen = false;
                    mSettingsMenuPending = true;
                    WatchUi.popView(WatchUi.SLIDE_DOWN);
                }
                Attention.vibrate([FocusVibration.profileForIndex(index)]);
            }
            mClock.setNextInterval(nowMs, mIntervalSettings.intervalMs(Math.rand()));
        }
        WatchUi.requestUpdate();
    }
}
