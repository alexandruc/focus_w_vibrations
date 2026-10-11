import Toybox.Graphics;
import Toybox.Lang;
import Toybox.WatchUi;

class FocusWithVibrationsView extends WatchUi.View {
    private var mSession as FocusSession;

    function initialize(session as FocusSession) {
        View.initialize();
        mSession = session;
    }

    function onUpdate(dc as Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_BLACK);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 4, Graphics.FONT_SMALL,
                    "Focus with vibrations", Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2 - dc.getFontHeight(Graphics.FONT_MEDIUM),
                    Graphics.FONT_XTINY, mSession.statusText(), Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() / 2,
                    Graphics.FONT_MEDIUM, FocusFormat.elapsedLabel(mSession.elapsedMs()),
                    Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth() / 2, dc.getHeight() * 3 / 4, Graphics.FONT_XTINY,
                    "Menu: controls", Graphics.TEXT_JUSTIFY_CENTER);
    }
}
