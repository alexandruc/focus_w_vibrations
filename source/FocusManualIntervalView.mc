import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class FocusManualIntervalView extends WatchUi.View {
    private var mCounter as FocusMinuteCounter;

    function initialize(counter as FocusMinuteCounter) {
        View.initialize();
        mCounter = counter;
    }

    function onUpdate(dc as Dc) as Void {
        var centerX = dc.getWidth() / 2;
        var rowY = FocusLayout.manualRows(dc.getHeight());
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, rowY[0], Graphics.FONT_MEDIUM,
                    "Manual interval", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, rowY[1], Graphics.FONT_LARGE,
                    mCounter.value().toString() + " min",
                    Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, rowY[2], Graphics.FONT_SMALL,
                    "Up +1 / Down -1 min", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(centerX, rowY[3], Graphics.FONT_XTINY,
                    "Start: Save  Back: Cancel", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
