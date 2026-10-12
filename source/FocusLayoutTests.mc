import Toybox.Test;
import Toybox.Lang;

(:test)
function testMainScreenRowsAreCenteredOn240PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRows(240);
    return y[0] == 48 && y[1] == 96 && y[2] == 144 && y[3] == 192 &&
           y[0] + y[3] == 240 && y[1] + y[2] == 240;
}

(:test)
function testMainScreenRowsScaleTo454PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRows(454);
    return y[0] == 90 && y[1] == 181 && y[2] == 272 && y[3] == 363 &&
           y[0] + y[3] == 453 && y[1] + y[2] == 453;
}
