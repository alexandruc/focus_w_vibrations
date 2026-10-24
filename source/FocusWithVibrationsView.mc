import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class FocusWithVibrationsView extends WatchUi.View {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        View.initialize();
        mSession = session;
    }

    function onShow() as Void {
        System.println("[AUTO-TRACE] main view onShow");
    }

    function onHide() as Void {
        System.println("[AUTO-TRACE] main view onHide");
    }

    function onUpdate(dc as Dc) as Void {
        var centerX = dc.getWidth() / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        if (mSession.popupVisible()) {
            var popupLines = mSession.popupLines();
            var popupFont = popupLines.size() > 1 ? Graphics.FONT_SMALL : Graphics.FONT_MEDIUM;
            var popupLineHeight = dc.getFontHeight(popupFont);
            var popupRows = FocusLayout.popupRows(dc.getHeight(), popupLineHeight, popupLines.size());
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
            for (var i = 0; i < popupLines.size(); i += 1) {
                dc.drawText(centerX, popupRows[i], popupFont, popupLines[i],
                            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            }
            return;
        }

        var mediumHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var smallHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var tinyHeight = dc.getFontHeight(Graphics.FONT_XTINY);
        var rowY = FocusLayout.mainRowsWithFonts(dc.getHeight(), mediumHeight, mediumHeight,
                                                 smallHeight, smallHeight, tinyHeight);
        var clockTime = System.getClockTime();
        var settings = System.getDeviceSettings();
        var timeLabel = FocusFormat.timeOfDayLabel(clockTime.hour, clockTime.min, settings.is24Hour);
        var elapsedLabel = FocusFormat.elapsedLabel(mSession.elapsedMs());

        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(centerX, rowY[0], Graphics.FONT_MEDIUM,
                    "Focus", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, rowY[1], Graphics.FONT_MEDIUM,
                    elapsedLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, rowY[2], Graphics.FONT_SMALL,
                    "Time of day", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(centerX, rowY[3], Graphics.FONT_SMALL,
                    timeLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (mSession.isReady()) {
            dc.drawText(centerX, rowY[4], Graphics.FONT_XTINY,
                        "Press Start to begin", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else if (mSession.isPaused()) {
            dc.drawText(centerX, rowY[4], Graphics.FONT_XTINY,
                        "Paused - press Start for options", Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}
