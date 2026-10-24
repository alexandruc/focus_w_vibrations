import Toybox.Lang;

module FocusActivityConfig {
    // FIT generic sport/sub-sport are enum value 0. Use the numeric values
    // because the named Activity constants only exist on API level 3.2+.
    const GENERIC_SPORT_ID = 0;
    const GENERIC_SUB_SPORT_ID = 0;

    function options() as Dictionary {
        return {
            :name => "Focus",
            :sport => GENERIC_SPORT_ID,
            :subSport => GENERIC_SUB_SPORT_ID
        };
    }
}
