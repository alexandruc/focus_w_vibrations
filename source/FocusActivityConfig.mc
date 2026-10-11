import Toybox.Activity;
import Toybox.Lang;

module FocusActivityConfig {
    function options() as Dictionary {
        return {
            :name => "Focus",
            :sport => Activity.SPORT_GENERIC,
            :subSport => Activity.SUB_SPORT_GENERIC
        };
    }
}
