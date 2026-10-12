import Toybox.Lang;

module FocusLayout {
    function mainRows(height as Number) as Array<Number> {
        return [height / 5, height * 2 / 5, height * 3 / 5, height * 4 / 5];
    }
}
