# Focus with vibrations

A Connect IQ watch app that records a FIT activity without requesting GPS/location, displays the active elapsed timer and local time, starts with the watch's Start/Select button, and pauses with that button while recording. Pausing opens a resource-backed system menu with Resume / Save / Discard. Each vibration shows a full-screen `FOCUS` notification for the pulse duration.

The main screen shows `Focus`, the active elapsed timer, then a smaller `Time of day` label with the actual local time on the following line (12/24-hour format follows device settings). All content rows are vertically centered.

Long-press the watch's Up/Menu button (about 800 ms) to enter the native system-style interval menu. It opens with the current choice first (Auto or Manual). Choosing Auto shows a full-screen, two-row `Random value up to 10 min` notification; Auto chooses a fresh active-time interval from 1–10 minutes at startup and after each alert. Choosing Manual opens a counter screen; Up/Down adjusts by one minute and Start saves. Manual values are limited to 1–60 minutes and start at 5. The selected mode and manual minutes persist across app relaunches.

The manifest targets all 116 currently catalogued Connect IQ watch-app profiles in the selected generation range, from the fēnix 6 era onward, with minimum API level 3.0. It covers Forerunner, fēnix, Venu, Instinct, epix, MARQ, D2, Approach, Descent, Enduro, and other watch families; exact product IDs are listed in `manifest.xml`. The list follows Garmin's [Compatible Devices catalog](https://developer.garmin.com/connect-iq/compatible-devices/) and the SDK Manager product catalog. Non-watch product classes and devices that cannot run watch apps are excluded. FIT sport/sub-sport are the generic enum values (`0`/`0`); Garmin Connect may label them “Other” or “Generic” depending on the product/account. The app does not request Positioning and records no GPS route or distance.

## Haptic behavior

This app emits one fixed-strength vibration pulse per alert and randomizes its duration from 500–3,000 ms. Hardware haptic strength and pattern support vary by watch; the app does not rely on multi-segment patterns. Verify motor behavior on physical devices.

## Local toolchain

This repository includes portable wrappers in `scripts/ciq-env.sh` and `scripts/connectiq`; they use project-relative paths and discover the selected SDK. SDK/JDK/device-pack binaries and private signing keys are deliberately not vendored. Install JDK 21, the Connect IQ SDK and SDK Manager from [Garmin's SDK page](https://developer.garmin.com/connect-iq/sdk/), then set `CIQ_HOME` and `CIQ_USER_HOME` or install them under the ignored project-local `.ciq-tools/` directory. The wrapper uses `.ciq-tools/home` by default for SDK Manager and Java state. If the SDK Manager CLI is installed elsewhere, set `CIQ_MANAGER` to its executable path. Download the manifest's device profiles with the SDK Manager CLI:

```sh
source scripts/ciq-env.sh
ciq_manager device download --manifest manifest.xml
```

The full simulator wrapper adds `CIQ_SIMULATOR_LIBS` only to the simulator process when configured.

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
export CIQ_DEVICE=fr970  # use any product ID listed in manifest.xml
mkdir -p bin
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}.prg" \
  -y "$CIQ_KEY"
```

## Tests

The test methods use Garmin Run No Evil and deterministic injected millisecond timestamps. Start the simulator with `scripts/connectiq` in one terminal, then build and run tests from another:

```sh
source scripts/ciq-env.sh
export CIQ_DEVICE=fr970  # use any product ID listed in manifest.xml
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" \
  -y "$CIQ_KEY" -t
monkeydo "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" "$CIQ_DEVICE" -t
```
Inspect the Run No Evil summary as well as the exit status; do not suppress or rewrite the exit code.

Compile for the product IDs in `manifest.xml` after their profiles are installed, and run the full suite on the minimum-API and latest-API targets (currently `approachs62` and `fr970`). A successful generic SDK build without `-d` does not prove target compatibility. Simulator success does not verify physical haptics, watch button behavior, FIT sync, or Garmin Connect's sport label.
