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
        var centerY = dc.getHeight() / 2;
        var mediumHeight = dc.getFontHeight(Graphics.FONT_MEDIUM);
        var smallHeight = dc.getFontHeight(Graphics.FONT_SMALL);
        var tinyHeight = dc.getFontHeight(Graphics.FONT_XTINY);
        var rowY = FocusLayout.mainRowsWithFonts(dc.getHeight(), mediumHeight, mediumHeight,
                                                 smallHeight, smallHeight, tinyHeight);
        var clockTime = System.getClockTime();
        var settings = System.getDeviceSettings();
        var timeLabel = FocusFormat.timeOfDayLabel(clockTime.hour, clockTime.min, settings.is24Hour);
        var elapsedLabel = FocusFormat.elapsedLabel(mSession.elapsedMs());

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
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

        if (mSession.popupVisible()) {
            var popupWidth = dc.getWidth() * 3 / 4;
            var popupHeight = dc.getFontHeight(Graphics.FONT_MEDIUM) * 2;
            var popupX = (dc.getWidth() - popupWidth) / 2;
            var popupY = (dc.getHeight() - popupHeight) / 2;
            dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_WHITE);
            dc.fillRectangle(popupX, popupY, popupWidth, popupHeight);
            dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_WHITE);
            dc.drawText(centerX, centerY, Graphics.FONT_MEDIUM, "FOCUS",
                        Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}
