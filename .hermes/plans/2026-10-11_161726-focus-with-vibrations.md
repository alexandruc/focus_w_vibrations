# Goal

Build a Connect IQ watch app named “Focus with vibrations” that starts and saves a FIT activity, displays active elapsed time, and emits a vibration alert on a configurable fixed or randomized active-time interval; on the selected Forerunner models, each alert is a single pulse no longer than 3 seconds because they do not support multi-profile vibration patterns.

# Current context / assumptions

- The workspace started empty and now contains the Connect IQ project, README, plan, test suite, and tool setup. The scaffold and implementation have been committed on `main`.
- Installed Connect IQ SDK 9.2.0 and Temurin JDK 21 under `/home/axelc/Work/garmin/tools/`; added the SDK Manager CLI there and generated a valid RSA developer key at `/home/axelc/Work/garmin/tools/developer_key.der` (permissions 0600).
- The requested product IDs are `fr245` (Forerunner 245, CIQ 3.3) and `fr970` (Forerunner 970, CIQ 6.0). Both device configurations are installed under `/home/axelc/Work/garmin/tools/home/.Garmin/ConnectIQ/Devices/`.
- Target-specific `monkeyc -w` release and test builds completed for both products (launcher icon autoscaling warnings only). All 37 Run No Evil tests printed `PASSED (passed=37, failed=0, errors=0)` on each simulator target; `monkeydo` returned exit status 1 after printing that pass summary, so preserve that exit-status caveat. A normal app launch initially reported a transient `Symbol Not Found` crash on fr245, but subsequent fr245 and fr970 launch attempts remained active through their 10–20 second timeouts. The simulator window was not accessible for visual interaction.
- The Ubuntu 22.04 WebKit/GTK runtime libraries are extracted under `/home/axelc/Work/garmin/tools/runtime-libs/ubuntu-jammy/`; the `connectiq` wrapper adds them locally without installing system packages. Simulator tests ran. Physical watch haptics and Garmin Connect sync/label still require on-device verification.
- Make this a `watch-app` with `Fit` and `Positioning` permissions. Garmin's RecordSample enables location events and creates a normal FIT recording with ActivityRecording.
- Garmin's documented sport enum has `Activity.SPORT_GENERIC` (“sport used for sports not on the list”) and `Activity.SUB_SPORT_GENERIC`; it does not document an `SPORT_OTHER` enum. Use `SPORT_GENERIC`, session name `Focus` (suggested maximum 15 characters), and verify the Connect label once profiles/device sync are available.
- Garmin documents that Forerunner devices do not support multi-profile vibration patterns. This app uses one fixed-strength pulse with randomized 500–3,000 ms duration. The interval is Auto (fresh random 1–10 active minutes per alert) or Manual (a custom 1–60 minutes counter adjusted with Up/Down). Auto is the default; Manual starts at 5 minutes. Pausing freezes active time, and a delayed tick emits at most one alert.

# Architecture / proposed approach

Use a Garmin Connect IQ `watch-app` with `Toybox.ActivityRecording` for the FIT session and a `FocusSession` controller for start/pause/resume/save/discard. Start/Select starts from Ready and pauses while recording; pause opens a resource-backed system Resume/Save/Discard menu. The system Menu behavior and a long-press of Up enter the resource-backed Auto/Manual interval menu. Auto selects a fresh random 1–10 minute active-time delay; Manual opens a custom Up/Down counter from 1–60 minutes. Show `Focus`, the active timer, a smaller `Time of day` label, and the local time on its own line in a vertically centered layout; overlay `FOCUS` for the vibration pulse duration.

# Step-by-step tasks

## 0. SDK, device profiles, and simulator runtime (installed locally)

1. Installed Connect IQ SDK 9.2.0 from Garmin's official Linux release into `/home/axelc/Work/garmin/tools/home/.Garmin/ConnectIQ/Sdks/` using the SDK Manager CLI. Installed Temurin JDK 21 at `/home/axelc/Work/garmin/tools/java/temurin-21/` and added `/home/axelc/Work/garmin/tools/ciq-env.sh` to configure paths.
2. The selected product IDs are `fr245` and `fr970`; both official configurations were downloaded into the SDK Manager's tools home. The local wrappers set Java's `user.home` so the compiler and simulator find them.
3. Generated a 4096-bit RSA developer key at `/home/axelc/Work/garmin/tools/developer_key.pem` and `/home/axelc/Work/garmin/tools/developer_key.der`; both are mode 0600 and outside the Git worktree.
4. The simulator libraries are now present under `tools/runtime-libs/ubuntu-jammy/usr/lib/x86_64-linux-gnu/`; `tools/bin/connectiq` loads them locally without changing system packages. Confirm with `source /home/axelc/Work/garmin/tools/ciq-env.sh && ldd "$CIQ_HOME/bin/simulator"` (no `not found` lines when run with the same `LD_LIBRARY_PATH` as the wrapper).

## 1. Scaffold and establish the build baseline (completed)

1. In the new project, retain the SDK-generated `manifest.xml`, `monkey.jungle`, and app entry-point boilerplate. Ensure these exact paths exist:
   - `manifest.xml`
   - `monkey.jungle`
   - `source/FocusWithVibrationsApp.mc`
   - `source/FocusWithVibrationsView.mc`
   - `source/FocusWithVibrationsDelegate.mc`
   - `resources/strings/strings.xml`
2. Set manifest app `type` to `watch-app`, `minApiLevel` to `3.2.0`, app name to `@Strings.AppName`, and product list to the selected model. Add only the needed permission inside the generated `<iq:permissions>` block:

```xml
<iq:uses-permission id="Fit"/>
```

3. Set the app string in `resources/strings/strings.xml`:

```xml
<string id="AppName">Focus with vibrations</string>
```

   Keep the XML root and other SDK-generated string entries intact.
4. Create `.gitignore` with:

```gitignore
*.der
*.pem
*.prg
*.iq
bin/
```

5. Initialize Git and commit the compiling scaffold. From the workspace root, set the SDK environment and build:

```sh
export CIQ_HOME="$(cat "$HOME/.Garmin/ConnectIQ/current-sdk.cfg")"
export PATH="$CIQ_HOME/bin:$PATH"
export CIQ_DEVICE='REPLACE_WITH_THE_SELECTED_SDK_DEVICE_ID'
export CIQ_KEY="$HOME/.Garmin/ConnectIQ/developer_key.der"
mkdir -p bin
git init -b main
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY"
```

   Replace the one device-ID value with the chosen model before running. Expected: `monkeyc` exits 0 and `bin/FocusWithVibrations.prg` exists. Then `git add .gitignore manifest.xml monkey.jungle resources source && git commit -m "chore: scaffold Focus with vibrations watch app"`; expected: one commit on `main`.

## 2. Add and test the active-time clock (TDD; 2–5 min)

1. First add `source/FocusClockTests.mc` with the complete test methods below. Run the named tests before adding behavior; the first RED run must fail because the tested behavior is absent, not because of a misspelled API.

```monkeyc
import Toybox.Test;

(:test)
function testFocusClockCountsRunningTime(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    return clock.elapsedAt(6000) == 5000;
}

(:test)
function testFocusClockFreezesWhenPaused(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(41000);
    return clock.elapsedAt(90000) == 40000;
}

(:test)
function testFocusClockExcludesPauseWhenResumed(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(41000);
    clock.resume(1041000);
    return clock.elapsedAt(1051000) == 50000;
}

(:test)
function testFocusClockDoesNotAlertBeforeFiveMinutes(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(0);
    return !clock.consumeAlert(299999);
}

(:test)
function testFocusClockAlertsOnceAtFiveMinutes(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(0);
    if (!clock.consumeAlert(300000)) { return false; }
    return !clock.consumeAlert(300000);
}

(:test)
function testFocusClockResetClearsElapsedTime(logger as Test.Logger) as Boolean {
    var clock = new FocusClock();
    clock.start(1000);
    clock.pause(6000);
    clock.reset();
    return clock.elapsedAt(8000) == 0 && !clock.consumeAlert(8000);
}
```

2. Implement `source/FocusClock.mc` with this small public contract: `start(nowMs)`, `pause(nowMs)`, `resume(nowMs)`, `elapsedAt(nowMs)`, `consumeAlert(nowMs)`, and `reset()`. Use `System.getTimer()` (milliseconds) from the app, but pass time into the helper so tests use deterministic values. `consumeAlert()` returns false while paused/not due; when due it returns true once and advances to the next future 300,000 ms boundary.
3. The helper implementation should follow this exact state logic (keep the fields and logic together; do not add persistence or configuration):

```monkeyc
using Toybox.Math;

class FocusClock {
    var mAccumulatedMs = 0;
    var mSegmentStartMs = 0;
    var mNextAlertMs = 300000;
    var mRunning = false;
    var mStarted = false;

    function initialize() { reset(); }

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
        if (!mStarted) { return 0; }
        if (!mRunning) { return mAccumulatedMs; }
        return mAccumulatedMs + nowMs - mSegmentStartMs;
    }

    function consumeAlert(nowMs as Number) as Boolean {
        if (!mRunning) { return false; }
        var elapsed = elapsedAt(nowMs);
        if (elapsed < mNextAlertMs) { return false; }
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
```

4. Prove RED, then GREEN, then run the full suite. Start `connectiq` in a separate terminal before `monkeydo`:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusClockAlertsOnceAtFiveMinutes
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusClockExcludesPauseWhenResumed
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
```

   RED: the named new test fails. GREEN/full-suite: output includes `PASSED (passed=37, failed=0, errors=0)`. Commit: `git add source/FocusClock.mc source/FocusClockTests.mc && git commit -m "feat: add pause-aware focus activity clock"`.

## 3. Add bounded random vibration patterns (TDD; 2–5 min)

1. Add `source/FocusVibrationTests.mc` first with tests that every one-pulse duration is `> 0` and `<= 3000` ms, and that non-negative random values map into the six valid indices. Run them RED before implementing the module.

```monkeyc
import Toybox.Test;
import Toybox.Lang;

(:test)
function testFocusPulseDurationsStayWithinThreeSeconds(logger as Test.Logger) as Boolean {
    for (var i = 0; i < FocusVibration.PATTERN_COUNT; i += 1) {
        var duration = FocusVibration.pulseLengthForIndex(i);
        if (duration <= 0 || duration > FocusVibration.MAX_TOTAL_MS) {
            return false;
        }
    }
    return true;
}

(:test)
function testRandomValueMapsToValidPulseIndex(logger as Test.Logger) as Boolean {
    for (var value = 0; value < 100; value += 1) {
        var index = FocusVibration.indexForRandomValue(value);
        if (index < 0 || index >= FocusVibration.PATTERN_COUNT) {
            return false;
        }
    }
    return true;
}
```

2. Implement `source/FocusVibration.mc` with six fixed-strength durations (`500`, `1000`, `1500`, `2000`, `2500`, and `3000` ms), one `Attention.VibeProfile` per alert, and this API: `PATTERN_COUNT`, `MAX_TOTAL_MS`, `indexForRandomValue(value)`, `pulseLengthForIndex(index)`, and `profileForIndex(index)`. This is a deliberate Forerunner fallback: Garmin says Forerunners do not render multi-profile vibration patterns, so randomize pulse length while keeping the entire event at or below 3,000 ms. The implementation is:

```monkeyc
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
        case 0: return 500;
        case 1: return 1000;
        case 2: return 1500;
        case 3: return 2000;
        case 4: return 2500;
        default: return MAX_TOTAL_MS;
        }
    }

    function profileForIndex(index as Number) as Attention.VibeProfile {
        return new Attention.VibeProfile(DUTY_CYCLE, pulseLengthForIndex(index));
    }
}
```


3. On each active 1-second tick, call `FocusVibration.indexForRandomValue(Math.rand())`, build one profile with `profileForIndex(index)`, and pass `[profile]` to `Attention.vibrate()` only if `Attention has :vibrate`. The call remains behind `FocusClock.consumeAlert()`.
4. Start `connectiq` in another terminal and run RED/GREEN for the named tests, then the suite:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusPulseDurationsStayWithinThreeSeconds
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testRandomValueMapsToValidPulseIndex
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
```

   RED: the new tests fail before the pulse helper exists. GREEN/full-suite: expected output includes `PASSED (passed=37, failed=0, errors=0)`. Commit: `git add source/FocusVibration.mc source/FocusVibrationTests.mc && git commit -m "feat: add bounded random focus vibrations"`.

## 4. Set the normal FIT activity type/name (TDD; 2–5 min)

1. Add `source/FocusActivityConfigTests.mc` first with this test. Run it RED before adding the config helper:

```monkeyc
import Toybox.Test;
using Toybox.Activity;

(:test)
function testDefaultActivityUsesGenericSportAndShortName(logger as Test.Logger) as Boolean {
    var options = FocusActivityConfig.options();
    return options[:name] == "Focus" &&
           options[:sport] == Activity.SPORT_GENERIC &&
           options[:subSport] == Activity.SUB_SPORT_GENERIC;
}
```

2. Add `source/FocusActivityConfig.mc`:

```monkeyc
using Toybox.Activity;

module FocusActivityConfig {
    function options() {
        return {
            :name => "Focus",
            :sport => Activity.SPORT_GENERIC,
            :subSport => Activity.SUB_SPORT_GENERIC
        };
    }
}
```

3. Build and run the targeted test before and after adding the helper, then the full suite. Start `connectiq` separately first:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testDefaultActivityUsesGenericSportAndShortName
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
```

   RED: the targeted test fails before the helper exists. GREEN/full-suite: expected `PASSED (passed=37, failed=0, errors=0)`. Commit: `git add source/FocusActivityConfig.mc source/FocusActivityConfigTests.mc && git commit -m "feat: configure generic FIT activity metadata"`.
4. Do not use a guessed `SPORT_OTHER` constant. The implementation uses the documented generic sport; only call it “Other” in user-facing text if Garmin Connect on the target actually labels it that way.

## 5. Wire the FIT session controller (TDD; 2–5 min)

1. Add `source/FocusSessionTests.mc` before `source/FocusSession.mc`. These Run No Evil integration tests use the simulator's actual ActivityRecording API; the finish test intentionally creates one short simulator FIT activity.

```monkeyc
import Toybox.Test;

(:test)
function testFocusSessionCanStartPauseResumeAndSave(logger as Test.Logger) as Boolean {
    var activity = new FocusSession();
    if (!activity.start()) { return false; }
    if (!activity.pause()) { activity.discard(); return false; }
    if (!activity.resume()) { activity.discard(); return false; }
    return activity.finish();
}

(:test)
function testFocusSessionCanDiscard(logger as Test.Logger) as Boolean {
    var activity = new FocusSession();
    if (!activity.start()) { return false; }
    return activity.discard();
}
```

   RED: build/run the two named tests and confirm they fail because the controller is absent. GREEN: after implementation, expect both to pass; use only the simulator so test FIT files do not appear on the user's watch.
2. Create `source/FocusSession.mc`. It owns exactly one `ActivityRecording.Session`, one `FocusClock`, and one repeating `Timer.Timer`. Implement Boolean-returning `start()`, `pause()`, `resume()`, `finish()`, and `discard()` methods with these rules:
   - `start()` calls `ActivityRecording.createSession(FocusActivityConfig.options())`; only after `session.start()` returns true does it start the clock at `System.getTimer()` and start the 1-second timer.
   - `pause()` calls `session.stop()`; only after success, pause the clock and stop the repeating timer.
   - `resume()` calls `session.start()`; only after success, resume the clock and restart the timer.
   - `finish()` stops the session if it is recording, then calls `session.save()`. On successful save, stop the timer, reset the clock, and clear the session reference. Return/report a failed Boolean rather than claiming success.
   - `discard()` stops an active session, calls `session.discard()`, and resets state only if the discard succeeds.
   - The repeating timer reads `System.getTimer()`, updates the view, and at each due active-time boundary chooses one single-profile random pulse. Use the same profile duration for the `FOCUS` popup timeout. If Start pauses the session while the popup is visible, defer the Resume/Save/Discard menu until that pulse-duration timeout ends.
3. TDD command sequence (start `connectiq` in another terminal first): build tests and run each named test before implementation; after implementation, run each again and then all tests:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusSessionCanStartPauseResumeAndSave
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusSessionCanDiscard
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
```

   RED: each named test fails because session operations are not implemented. GREEN/full-suite: output includes `PASSED (passed=37, failed=0, errors=0)`. Commit: `git add source/FocusSession.mc source/FocusSessionTests.mc && git commit -m "feat: record focus sessions as FIT activities"`.

## 6. Build the watch screen and controls (2–5 min)

1. Update `source/FocusWithVibrationsApp.mc` to return the timer `View` and its delegate from `getInitialView()` using the generated app entry-point pattern.
2. Update `source/FocusWithVibrationsView.mc` to show the title `Focus`, then the `HH:MM:SS` active elapsed timer, then local time in the device's clock format. Obtain local time with `System.getClockTime()` and select 24-hour vs 12-hour formatting with `System.getDeviceSettings().is24Hour`. Add the 12/24-hour cases to `source/FocusFormatTests.mc` before implementing `FocusFormat.timeOfDayLabel(hour, minute, is24Hour)` in `source/FocusFormat.mc`. Keep Ready/Paused hints below these three lines; draw a centered `FOCUS` overlay while `FocusSession.popupVisible()` is true.

```monkeyc
import Toybox.Test;
import Toybox.Lang;

(:test)
function testElapsedTimerFormatting(logger as Test.Logger) as Boolean {
    return FocusFormat.elapsedLabel(0).equals("00:00:00") &&
           FocusFormat.elapsedLabel(59000).equals("00:00:59") &&
           FocusFormat.elapsedLabel(60000).equals("00:01:00") &&
           FocusFormat.elapsedLabel(3600000).equals("01:00:00");
}

(:test)
function testClockFormattingFollows24HourSetting(logger as Test.Logger) as Boolean {
    return FocusFormat.timeOfDayLabel(0, 7, true).equals("00:07") &&
           FocusFormat.timeOfDayLabel(13, 5, true).equals("13:05");
}

(:test)
function testClockFormattingFollows12HourSetting(logger as Test.Logger) as Boolean {
    return FocusFormat.timeOfDayLabel(0, 7, false).equals("12:07 AM") &&
           FocusFormat.timeOfDayLabel(12, 0, false).equals("12:00 PM") &&
           FocusFormat.timeOfDayLabel(13, 5, false).equals("1:05 PM");
}
```

   RED: the named test fails before `FocusFormat` exists. Then implement `source/FocusFormat.mc`:

```monkeyc
using Toybox.Math;

module FocusFormat {
    function twoDigits(value as Number) as String {
        var text = value.toString();
        if (value < 10) { return "0" + text; }
        return text;
    }

    function elapsedLabel(elapsedMs as Number) as String {
        var totalSeconds = Math.floor(elapsedMs / 1000);
        var hours = Math.floor(totalSeconds / 3600);
        var minutes = Math.floor((totalSeconds % 3600) / 60);
        var seconds = totalSeconds % 60;
        return twoDigits(hours) + ":" + twoDigits(minutes) + ":" + twoDigits(seconds);
    }

    function timeOfDayLabel(hour as Number, minute as Number, is24Hour as Boolean) as String {
        if (is24Hour) {
            return twoDigits(hour) + ":" + twoDigits(minute);
        }
        var displayHour = hour % 12;
        if (displayHour == 0) { displayHour = 12; }
        var suffix = "AM";
        if (hour >= 12) { suffix = "PM"; }
        return displayHour.toString() + ":" + twoDigits(minute) + " " + suffix;
    }
}
```

   GREEN: build/run the named test and the full suite with the SDK simulator running; expected output includes `PASSED (passed=37, failed=0, errors=0)`:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testElapsedTimerFormatting
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
```

3. Update `source/FocusWithVibrationsDelegate.mc` so `onSelect()` starts the session from Ready, pauses it while Recording, and opens `FocusMenus.showPausedMenu()` once Paused. Pressing Start while the vibration popup is still active defers the menu until the popup timer expires. Keep the paused menu limited to `Resume`, `Save`, and `Discard`; Back dismisses the menu without silently saving/discarding. Add `source/FocusMenusTests.mc` first and prove the menu labels with Run No Evil before implementing `source/FocusMenus.mc`.
4. Rebuild and run all unit tests. Expected: `PASSED (passed=37, failed=0, errors=0)` on each target. Commit: `git add source && git commit -m "feat: add activity timer screen and controls"`.

## 7. Verify on simulator and target watch (manual integration; 2–5 min setup, longer for 5-minute check)

1. Build a non-unit-test PRG and launch the simulator:

```sh
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY"
```

   Run `connectiq` in a separate terminal, then:

```sh
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE"
```

2. In the simulator, verify: Start/Select begins recording from Ready; Start/Select pauses while recording and shows the paused menu; Resume restarts active time; Save closes the FIT session; Discard closes without saving; the running view shows `Focus`, timer, and system-format local time; the `FOCUS` overlay remains until the pulse duration expires. Verify no runtime exceptions.
3. Install/run on each selected watch. Confirm activity placement, saved FIT sync, and Garmin Connect's sport label; check physical haptic feedback because simulator tests cannot prove vibration motor behavior.
4. Open the interval menu with long-press Up/Menu, choose Manual, set 1 minute, and confirm; verify one alert at the one-minute active-time boundary. Reopen the menu, choose Auto, and verify successive alert gaps are within 1–10 minutes. Pause and confirm active time freezes; resume and verify the countdown continues from its remaining value.
5. Expected completion evidence: target builds and test suites pass for both IDs, simulator controls/screen behave as specified, and a real watch saves/syncs the activity. Commit any fixes separately and rerun the affected tests.

# Tests / validation

- Follow RED → GREEN → REFACTOR for every new pure behavior: write one focused `(:test)` method first, run only that method with Run No Evil, confirm the expected failure, implement the minimum, rerun to pass, then run the full suite and commit.
- Run No Evil command-line workflow per Garmin documentation:

```sh
# Build unit tests; connectiq must already be running in another terminal.
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle -o bin/FocusWithVibrations.prg -y "$CIQ_KEY" -t
# Run all tests:
monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t
# Expected final line:
# PASSED (passed=37, failed=0, errors=0)
```

- For a focused test, pass its exact method name after `-t`, e.g. `monkeydo bin/FocusWithVibrations.prg "$CIQ_DEVICE" -t testFocusClockExcludesPauseWhenResumed`.
- Run a release/simulator build without `-t` after all tests pass. Check `git status --short` and ensure no private signing key, generated `.prg`, or generated `.iq` file is tracked.
- Simulator cannot confirm motor haptics, physical button/menu behavior, app availability in the Activities list on every product, or Garmin Connect sport-label interpretation; those are target-device checks, not claims inferred from a successful build.

# Risks, tradeoffs, and open questions

- Both target profiles are installed. Compiler wrappers now set `JAVA_TOOL_OPTIONS=-Duser.home=/home/axelc/Work/garmin/tools/home`; use the wrappers loaded by `source /home/axelc/Work/garmin/tools/ciq-env.sh` for target builds and tests.
- Does Garmin Connect render `SPORT_GENERIC` as “Other,” “Generic,” or another label on the two watches? Garmin's Connect IQ enum documents `SPORT_GENERIC`, not `SPORT_OTHER`; verify on device before promising the exact UI label.
- Garmin documents that Forerunner models do not render multi-profile vibration patterns. This build uses randomized single-pulse durations (500–3,000 ms) at fixed strength; if the user requires multi-segment on/off patterns, these initial target devices cannot provide them through the documented Connect IQ API.
- The Ubuntu 22.04 WebKit/GTK packages were extracted under `tools/runtime-libs/ubuntu-jammy/` to satisfy the simulator without system-level package changes. Launch it with the `connectiq` wrapper so `LD_LIBRARY_PATH` is set.
- Positioning is enabled during active recording so standard FIT sessions can include GPS updates. Verify outdoors/on-device; simulator location simulation alone does not prove GPS behavior.
- The activity title sent to FIT is deliberately `Focus`, not the full app title, to stay within Garmin's suggested 15-character session-name limit.

# References

- Garmin Activity Recording: https://developer.garmin.com/connect-iq/core-topics/activity-recording/
- ActivityRecording API and sport enums: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording.html
- ActivityRecording.Session API: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html
- Attention vibration and VibeProfile API: https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html
- Timer API: https://developer.garmin.com/connect-iq/api-docs/Toybox/Timer/Timer.html
- Manifest permissions / Fit permission: https://developer.garmin.com/connect-iq/core-topics/manifest-and-permissions/
- Monkey C command-line setup: https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/
- Run No Evil unit testing: https://developer.garmin.com/connect-iq/core-topics/unit-testing/
