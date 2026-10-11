import Toybox.Graphics;
import Toybox.WatchUi;

class FocusWithVibrationsView extends WatchUi.View {
    function initialize() {
        View.initialize();
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 3, Graphics.FONT_SMALL,
                    "Focus with vibrations", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2, Graphics.FONT_MEDIUM,
                    "Ready", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 2 / 3, Graphics.FONT_XTINY,
                    "Press Menu for Start", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
