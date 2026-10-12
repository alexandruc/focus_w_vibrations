import Toybox.Lang;

module FocusLongPress {
    const MENU_HOLD_MS = 800;

    function isMenuHold(heldMs as Number) as Boolean {
        return heldMs >= MENU_HOLD_MS;
    }
}
