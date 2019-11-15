(function (global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    var interstitialQuestion = {
        init: function () {
            interstitialQuestion.$form = $('#interstitial-question-form');
            interstitialQuestion.interstitialQuestionDetails = $('#interstitial_question_details');
            interstitialQuestion.setInterstitialQuestionDetailsVisibility();
            interstitialQuestion.$form.find('input[name="interstitial_question_form[interstitial_question_result]"]').on('click', interstitialQuestion.setInterstitialQuestionDetailsVisibility);
        },

        setInterstitialQuestionDetailsVisibility: function () {
            interstitialQuestion.interstitialQuestionDetails.addClass('hidden');
            interstitialQuestion.interstitialQuestionDetails.removeClass('form-group-error');
        }
    };

    GOVUK.interstitialQuestion = interstitialQuestion;

    global.GOVUK = GOVUK;
})(window);
