import Toybox.ActivityRecording;
import Toybox.Application;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.Math;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

class FocusSession {
    const INTERVAL_MODE_STORAGE_KEY = "focus_interval_mode";
    const INTERVAL_MINUTES_STORAGE_KEY = "focus_interval_minutes";

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
        loadIntervalSettings();
    }

    function start() as Boolean {
        if (mSession != null || !(Toybox has :ActivityRecording)) {
            mMessage = "Unable to start";
            WatchUi.requestUpdate();
            return false;
        }

        mSession = ActivityRecording.createSession(FocusActivityConfig.options());
        if (!mSession.start()) {
            mSession.discard();
            mSession = null;
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
        mState = :paused;
        mMessage = "";
        WatchUi.requestUpdate();
        return true;
    }

    function resume() as Boolean {
        if (mSession == null || mState != :paused) {
            return false;
        }

        if (!mSession.start()) {
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

    function popupText() as String {
        return mPopup.message();
    }

    function popupLines() as Array<String> {
        return mPopup.displayLines();
    }

    function showAutoSelectionPopup() as Void {
        var durationMs = 2500;
        var nowMs = System.getTimer();
        mPopup.beginMessage(nowMs, durationMs, "Random value up to 10 min");
        mPopupTimer.stop();
        mPopupTimer.start(method(:onPopupEnd), durationMs, false);
        WatchUi.requestUpdate();
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

    function setManualVibrationInterval(minutes as Number) as Void {
        mIntervalSettings.setManualMinutes(minutes);
        persistIntervalSettings();
        rescheduleUpcomingInterval();
    }

    function setAutoVibrationInterval() as Void {
        System.println("[AUTO-TRACE] session.setAutoVibrationInterval entered");
        mIntervalSettings.useAuto();
        persistIntervalSettings();
        System.println("[AUTO-TRACE] session interval mode=" + mIntervalSettings.label());
        rescheduleUpcomingInterval();
        System.println("[AUTO-TRACE] session.setAutoVibrationInterval returned");
    }

    function manualVibrationMinutes() as Number {
        return mIntervalSettings.minutes();
    }

    function isAutoVibrationInterval() as Boolean {
        return mIntervalSettings.isAuto();
    }

    function vibrationIntervalLabel() as String {
        return mIntervalSettings.label();
    }

    function showIntervalModeMenuWhenReady() as Void {
        System.println("[AUTO-TRACE] showIntervalModeMenuWhenReady entered");
        if (mSettingsMenuOpen || mSettingsMenuPending) {
            System.println("[AUTO-TRACE] interval menu request ignored; already open/pending");
            return;
        }
        if (popupVisible()) {
            System.println("[AUTO-TRACE] interval menu deferred while popup visible");
            mSettingsMenuPending = true;
            return;
        }
        mSettingsMenuPending = false;
        mSettingsMenuOpen = true;
        System.println("[AUTO-TRACE] interval menu state set open; pushing view");
        FocusMenus.showIntervalModeMenu(self);
        System.println("[AUTO-TRACE] interval menu push returned");
    }

    function closeIntervalMenu() as Void {
        System.println("[AUTO-TRACE] closeIntervalMenu entered");
        mSettingsMenuOpen = false;
        mSettingsMenuPending = false;
        System.println("[AUTO-TRACE] closeIntervalMenu returned");
    }

    private function loadIntervalSettings() as Void {
        var savedMinutes = Application.Storage.getValue(INTERVAL_MINUTES_STORAGE_KEY);
        if (savedMinutes != null) {
            mIntervalSettings.setManualMinutes(savedMinutes as Number);
        }

        var savedMode = Application.Storage.getValue(INTERVAL_MODE_STORAGE_KEY);
        if (savedMode != null && savedMode.equals("manual")) {
            if (savedMinutes == null) {
                mIntervalSettings.setManualMinutes(5);
            }
        } else {
            mIntervalSettings.useAuto();
        }
    }

    private function persistIntervalSettings() as Void {
        var mode = mIntervalSettings.isAuto() ? "auto" : "manual";
        Application.Storage.setValue(INTERVAL_MODE_STORAGE_KEY, mode);
        Application.Storage.setValue(INTERVAL_MINUTES_STORAGE_KEY, mIntervalSettings.minutes());
    }

    private function rescheduleUpcomingInterval() as Void {
        System.println("[AUTO-TRACE] rescheduleUpcomingInterval entered");
        if (mState == :recording || mState == :paused) {
            var nowMs = System.getTimer();
            var randomValue = Math.rand();
            var intervalMs = mIntervalSettings.intervalMs(randomValue);
            System.println("[AUTO-TRACE] reschedule values random=" + randomValue.toString() + " interval_ms=" + intervalMs.toString());
            System.println("[AUTO-TRACE] clock.setNextInterval begin");
            mClock.setNextInterval(nowMs, intervalMs);
            System.println("[AUTO-TRACE] clock.setNextInterval returned");
        } else {
            System.println("[AUTO-TRACE] reschedule skipped; session not recording/paused");
        }
        System.println("[AUTO-TRACE] WatchUi.requestUpdate begin");
        WatchUi.requestUpdate();
        System.println("[AUTO-TRACE] WatchUi.requestUpdate returned");
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
            FocusMenus.showIntervalModeMenu(self);
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
