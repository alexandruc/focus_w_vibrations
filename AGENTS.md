# AGENTS.md

Tool-agnostic project guidance for coding agents and contributors. This replaces the former `.hermes` implementation plan: its completed step-by-step scaffold/TDD instructions were historical, so this file keeps the still-relevant project context and working constraints. For current setup commands and user-facing behavior, `README.md`, the source, manifest, and tests are authoritative.

## Project

Focus with vibrations is a Garmin Connect IQ watch app for Forerunner 245 (`fr245`) and Forerunner 970 (`fr970`). It records a FIT activity named `Focus`, displays active elapsed time and local time, and vibrates at configurable intervals.

The app requests only the `Fit` permission. It does not use Positioning and must not record GPS, route, or distance data. The FIT sport/sub-sport are `Activity.SPORT_GENERIC` and `Activity.SUB_SPORT_GENERIC`; do not promise an exact Garmin Connect label without checking a real sync.

## Behavior and design constraints

- Start/Select starts a session from Ready and pauses it while recording. The paused system menu offers Resume, Save, and Discard.
- Active elapsed time excludes pauses. A delayed timer tick should emit at most one alert and schedule the next interval from active time.
- Auto is the default: choose a fresh random interval from 1–10 active minutes at session start and after each alert. Its selection notice is the centered, two-row full-screen text `Random value up to 10 min`.
- Manual intervals are 1–60 minutes, initially 5. The Auto/Manual choice and manual minutes persist between app runs; open the interval menu with the current choice first.
- Forerunner vibration is a single fixed-strength pulse per alert, with randomized duration from 500–3,000 ms. Do not implement or promise multi-profile vibration patterns on these targets.
- The main screen centers `Focus`, the elapsed timer, a `Time of day` label, and the actual local time on separate rows. The notification covers the screen for the pulse duration.
- Use native resource-backed system menus. A menu selection completes its own view transition; do not add a redundant `WatchUi.popView()` after selecting a menu item.

## Toolchain and safety

Read `README.md` for portable setup instructions. The repository includes `scripts/ciq-env.sh` and `scripts/connectiq`; SDK, JDK, device profiles, runtime libraries, and a private developer key are machine-specific and are not vendored. Use `CIQ_HOME`, `CIQ_USER_HOME`, `CIQ_TOOLS_HOME`, `CIQ_KEY`, and `CIQ_SIMULATOR_LIBS` as documented there.

Never commit private signing material, downloaded SDK/toolchain files, runtime libraries, or generated `.prg`/`.iq` build artifacts. Do not read or print credential files when inspecting the repository.

## Build and test

Run from the repository root. Start the simulator in one terminal with `scripts/connectiq`; source the environment in another terminal before invoking SDK commands. Build and run Run No Evil tests for both device IDs before considering target compatibility verified:

```sh
source scripts/ciq-env.sh
export CIQ_DEVICE=fr245  # repeat with fr970
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" \
  -y "$CIQ_KEY" -t
monkeydo "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" "$CIQ_DEVICE" -t
```

Inspect both the test summary and command status; do not mask failures. Also run a release build without `-t`. Simulator success does not verify physical haptics, watch button behavior, FIT sync, or Garmin Connect's sport label; call out those limitations unless verified on-device.

## Implementation and test practices

- Follow existing Monkey C style and APIs documented by the installed Connect IQ SDK; inspect neighboring code before introducing symbols or dependencies.
- For pure logic, write focused tests first and use deterministic inputs/timestamps. Run the targeted test, then the complete suite on both targets.
- Preserve explicit failure handling for ActivityRecording operations; only transition/reset session state after the corresponding operation succeeds.
- Keep changes scoped. Update tests and `README.md` when user-visible behavior or setup changes.

## Relevant source files

- `source/FocusSession.mc`: FIT lifecycle, active-time timer, interval persistence, popup state, and alert scheduling.
- `source/FocusIntervalSettings.mc`: Auto/Manual interval calculation and bounds.
- `source/FocusIntervalMenuDelegate.mc`, `source/FocusMenus.mc`, and `resources/menus/`: interval and paused menus.
- `source/FocusWithVibrationsView.mc`, `source/FocusLayout.mc`, and popup/layout helpers: screen and notification rendering.
- `source/*Tests.mc`: Run No Evil coverage for session, settings, menus, timing, and layout.
- `manifest.xml`: supported products and the Fit-only permission.

## Official references

- Activity Recording: https://developer.garmin.com/connect-iq/core-topics/activity-recording/
- ActivityRecording API: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording.html
- ActivityRecording.Session API: https://developer.garmin.com/connect-iq/api-docs/Toybox/ActivityRecording/Session.html
- Attention vibration API: https://developer.garmin.com/connect-iq/api-docs/Toybox/Attention.html
- Timer API: https://developer.garmin.com/connect-iq/api-docs/Toybox/Timer/Timer.html
- Manifest permissions: https://developer.garmin.com/connect-iq/core-topics/manifest-and-permissions/
- Monkey C command-line setup: https://developer.garmin.com/connect-iq/reference-guides/monkey-c-command-line-setup/
- Run No Evil unit testing: https://developer.garmin.com/connect-iq/core-topics/unit-testing/
