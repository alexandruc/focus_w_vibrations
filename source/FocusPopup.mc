import Toybox.Lang;

class FocusPopup {
    private var mEndMs = 0;
    private var mActive = false;
    private var mMessage = "";

    function initialize() {
        clear();
    }

    function begin(startMs as Number, durationMs as Number) as Void {
        mEndMs = startMs + durationMs;
        mActive = durationMs > 0;
        mMessage = "FOCUS";
    }

    function beginMessage(startMs as Number, durationMs as Number, message as String) as Void {
        mEndMs = startMs + durationMs;
        mActive = durationMs > 0;
        mMessage = message;
    }

    function message() as String {
        return mMessage;
    }

    function displayLines() as Array<String> {
        if (mMessage.equals("Random value up to 10 min")) {
            return ["Random value up to", "10 min"];
        }
        return [mMessage];
    }

    function isVisible(nowMs as Number) as Boolean {
        if (!mActive) {
            return false;
        }
        if (nowMs >= mEndMs) {
            mActive = false;
            return false;
        }
        return true;
    }

    function clear() as Void {
        mEndMs = 0;
        mActive = false;
        mMessage = "";
    }
}
