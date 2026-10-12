import Toybox.Test;
import Toybox.Lang;

(:test)
function testMainRowsAddConsistentVerticalGapsOn240PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRowsWithFonts(240, 20, 20, 14, 14, 8);
    return y[0] == 80 && y[1] == 106 && y[2] == 129 && y[3] == 149 && y[4] == 166 &&
           y[1] - y[0] >= 26 && y[2] - y[1] >= 20 &&
           y[0] - 10 == 70 && y[4] + 4 == 170 &&
           (y[0] - 10) + (y[4] + 4) == 240;
}

(:test)
function testMainRowsScaleWithFontMetricsOn454PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRowsWithFonts(454, 28, 28, 18, 18, 10);
    return y[0] == 168 && y[1] == 207 && y[2] == 241 && y[3] == 270 && y[4] == 295 &&
           y[1] - y[0] >= 39 && y[2] - y[1] >= 34 &&
           y[0] - 14 == 154 && y[4] + 5 == 300 &&
           (y[0] - 14) + (y[4] + 5) == 454;
}

(:test)
function testManualCounterRowsStayCentered(logger as Test.Logger) as Boolean {
    var y = FocusLayout.manualRows(240);
    return y[0] == 48 && y[1] == 96 && y[2] == 144 && y[3] == 192 &&
           y[0] + y[3] == 240 && y[1] + y[2] == 240;
}
