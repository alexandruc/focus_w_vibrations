import Toybox.Lang;

module FocusLongPress {
    const SETTINGS_HOLD_MS = 800;

    function isSettingsHold(heldMs as Number) as Boolean {
        return heldMs >= SETTINGS_HOLD_MS;
    }
}
