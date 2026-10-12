import Toybox.Test;
import Toybox.Lang;

(:test)
function testMainScreenRowsAreCenteredOn240PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRows(240);
    return y[0] == 40 && y[1] == 80 && y[2] == 120 && y[3] == 160 && y[4] == 200 &&
           y[0] + y[4] == 240 && y[1] + y[3] == 240 && y[2] == 120;
}

(:test)
function testMainScreenRowsScaleTo454PixelDisplay(logger as Test.Logger) as Boolean {
    var y = FocusLayout.mainRows(454);
    return y[0] == 75 && y[1] == 151 && y[2] == 227 && y[3] == 302 && y[4] == 378 &&
           y[0] + y[4] == 453 && y[1] + y[3] == 453 && y[2] == 227;
}
