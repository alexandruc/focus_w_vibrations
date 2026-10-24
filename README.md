# Focus with vibrations

A Connect IQ watch app that records a FIT activity without requesting GPS/location, displays the active elapsed timer and local time, starts with the watch's Start/Select button, and pauses with that button while recording. Pausing opens a resource-backed system menu with Resume / Save / Discard. Each vibration shows a full-screen `FOCUS` notification for the pulse duration.

The main screen shows `Focus`, the active elapsed timer, then a smaller `Time of day` label with the actual local time on the following line (12/24-hour format follows device settings). All content rows are vertically centered.

Long-press the watch's Up/Menu button (about 800 ms) to enter the native system-style interval menu. It opens with the current choice first (Auto or Manual). Choosing Auto shows a full-screen, two-row `Random value up to 10 min` notification; Auto chooses a fresh active-time interval from 1–10 minutes at startup and after each alert. Choosing Manual opens a counter screen; Up/Down adjusts by one minute and Start saves. Manual values are limited to 1–60 minutes and start at 5. The selected mode and manual minutes persist across app relaunches.

Supported product IDs: `fr245` (Forerunner 245) and `fr970` (Forerunner 970). The manifest targets both. FIT sport/sub-sport are `Activity.SPORT_GENERIC` and `Activity.SUB_SPORT_GENERIC`; the app does not request Positioning and records no GPS route or distance. Garmin Connect may label this “Other” or “Generic” depending on the product/account.

## Forerunner haptic limitation

Garmin's `Toybox.Attention.vibrate()` documentation states that Forerunner devices do not support vibration patterns and may vibrate at a constant duty cycle. This app therefore uses one profile per alert at fixed strength and randomizes the pulse duration (500–3,000 ms). It does not claim that the Forerunner 245/970 can play multi-segment on/off patterns.

## Local toolchain

This repository includes portable wrappers in `scripts/ciq-env.sh` and `scripts/connectiq`; they use project-relative paths and discover the selected SDK. SDK/JDK/device-pack binaries and private signing keys are deliberately not vendored. Install JDK 21, the Connect IQ SDK and the `fr245`/`fr970` device profiles from [Garmin's SDK page](https://developer.garmin.com/connect-iq/sdk/), then either set `CIQ_HOME` and `CIQ_USER_HOME` or install them under the ignored project-local `.ciq-tools/` directory. The wrapper uses `.ciq-tools/home` by default for SDK Manager and Java state.

From the repository root, source the environment and start the simulator with:

```sh
source scripts/ciq-env.sh
scripts/connectiq
```

To sign builds, provide your own private developer key. The default expected path is `.ciq-tools/developer_key.der`; it is ignored by Git. Generate a key only for your own developer account and keep it private:

```sh
CIQ_TOOLS_HOME="${CIQ_TOOLS_HOME:-$PWD/.ciq-tools}"
mkdir -p "$CIQ_TOOLS_HOME"
openssl genrsa -out "$CIQ_TOOLS_HOME/developer_key.pem" 4096
openssl pkcs8 -topk8 -inform PEM -outform DER \
  -in "$CIQ_TOOLS_HOME/developer_key.pem" \
  -out "$CIQ_TOOLS_HOME/developer_key.der" -nocrypt
chmod 600 "$CIQ_TOOLS_HOME/developer_key.pem" "$CIQ_TOOLS_HOME/developer_key.der"
export CIQ_KEY="$CIQ_TOOLS_HOME/developer_key.der"
```

If the Linux simulator needs legacy GTK/WebKit libraries, set `CIQ_SIMULATOR_LIBS` to a local compatible library directory; `scripts/connectiq` adds it only to the simulator process. Do not commit downloaded SDK files, runtime libraries, or keys.

## Build

After device profiles are installed:

```sh
source scripts/ciq-env.sh
export CIQ_DEVICE=fr245  # or fr970
mkdir -p bin
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}.prg" \
  -y "$CIQ_KEY"
```

## Tests

The test methods use Garmin Run No Evil and deterministic injected millisecond timestamps. Start the simulator with `scripts/connectiq` in one terminal, then build and run tests from another:

```sh
source scripts/ciq-env.sh
export CIQ_DEVICE=fr245  # or fr970
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" \
  -y "$CIQ_KEY" -t
monkeydo "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" "$CIQ_DEVICE" -t
```

On this Arch host, `monkeydo` prints the complete `PASSED (passed=42, failed=0, errors=0)` result for each target but exits with status 1 after the summary. Inspect the Run No Evil summary as well as the exit status; do not suppress or rewrite the exit code.

Run on both target IDs before considering the app device-verified. A successful compiler run without `-d` only validates a generic SDK build; it does not prove target compatibility or simulator behavior.
