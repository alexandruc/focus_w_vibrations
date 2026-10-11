# Focus with vibrations

A Connect IQ watch app that records a FIT activity, displays elapsed activity time, and emits a randomized haptic pulse every five minutes of active time.

Supported product IDs: `fr245` (Forerunner 245) and `fr970` (Forerunner 970). The manifest targets both. FIT sport/sub-sport are `Activity.SPORT_GENERIC` and `Activity.SUB_SPORT_GENERIC`; Garmin Connect may label this “Other” or “Generic” depending on the product/account.

## Forerunner haptic limitation

Garmin's `Toybox.Attention.vibrate()` documentation states that Forerunner devices do not support vibration patterns and may vibrate at a constant duty cycle. This app therefore uses one profile per alert at fixed strength and randomizes the pulse duration (500–3,000 ms). It does not claim that the Forerunner 245/970 can play multi-segment on/off patterns.

## Local toolchain

The SDK, JDK, SDK Manager CLI, and signing key are kept outside this project under `/home/axelc/Work/garmin/tools/`. Load the environment with:

```sh
source /home/axelc/Work/garmin/tools/ciq-env.sh
```

The private key is `/home/axelc/Work/garmin/tools/developer_key.der`; do not copy it into the repository or publish it. The repository ignores generated `.prg`/`.iq` builds and local key files.

Device configurations are separate from the SDK. After Garmin SSO is available, complete the SDK Manager login and download the target device profiles:

```sh
ciq_manager login
# Open the login URL printed by the command in a normal browser and authorize.
ciq_manager device download --device fr245 --device fr970 --include-fonts
```

The current development environment may still need the simulator's Linux runtime libraries before `connectiq` can launch.

## Build

After device profiles are installed:

```sh
source /home/axelc/Work/garmin/tools/ciq-env.sh
export CIQ_DEVICE=fr245  # or fr970
mkdir -p bin
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}.prg" \
  -y "$CIQ_KEY"
```

## Tests

The test methods use Garmin Run No Evil and deterministic injected millisecond timestamps. Start the Connect IQ simulator in one terminal, then build and run tests from another:

```sh
source /home/axelc/Work/garmin/tools/ciq-env.sh
export CIQ_DEVICE=fr245  # or fr970
monkeyc -d "$CIQ_DEVICE" -f monkey.jungle \
  -o "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" \
  -y "$CIQ_KEY" -t
monkeydo "bin/FocusWithVibrations-${CIQ_DEVICE}-tests.prg" "$CIQ_DEVICE" -t
```

Run on both target IDs before considering the app device-verified. A successful compiler run without `-d` only validates a generic SDK build; it does not prove target compatibility or simulator behavior.
