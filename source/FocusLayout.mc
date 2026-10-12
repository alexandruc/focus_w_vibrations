import Toybox.Lang;

module FocusLayout {
    function mainRows(height as Number) as Array<Number> {
        return [height / 6, height * 2 / 6, height * 3 / 6, height * 4 / 6, height * 5 / 6];
    }
}
