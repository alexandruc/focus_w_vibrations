import Toybox.Lang;

module FocusLayout {
    function manualRows(height as Number) as Array<Number> {
        return [height / 5, height * 2 / 5, height * 3 / 5, height * 4 / 5];
    }

    function popupRows(height as Number, lineHeight as Number, rowCount as Number) as Array<Number> {
        if (rowCount <= 1) {
            return [height / 2];
        }
        var firstY = height / 2 - ((rowCount - 1) * lineHeight) / 2;
        var rows = [firstY];
        for (var i = 1; i < rowCount; i += 1) {
            rows.add(firstY + i * lineHeight);
        }
        return rows;
    }

    function mainRowsWithFonts(height as Number, titleHeight as Number, timerHeight as Number, labelHeight as Number, timeHeight as Number, statusHeight as Number) as Array<Number> {
        var gap = height / 40;
        if (gap < 4) {
            gap = 4;
        }
        var totalHeight = titleHeight + timerHeight + labelHeight + timeHeight + statusHeight + gap * 4;
        var cursorY = (height - totalHeight) / 2;
        var rows = [cursorY + titleHeight / 2];
        cursorY += titleHeight + gap;
        rows.add(cursorY + timerHeight / 2);
        cursorY += timerHeight + gap;
        rows.add(cursorY + labelHeight / 2);
        cursorY += labelHeight + gap;
        rows.add(cursorY + timeHeight / 2);
        cursorY += timeHeight + gap;
        rows.add(cursorY + statusHeight / 2);
        return rows;
    }
}
