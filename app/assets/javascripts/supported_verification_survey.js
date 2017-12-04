(function(global) {
    "use strict";
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    GOVUK.supportedVerificationSurvey = {
        init: function() {
            var supportedVerificationSurvey = $('.supported-verification-survey');

            function recordResponse(response) {
                global._paq.push(['trackEvent', 'Micro Survey', response, 'F2F Support']);
                supportedVerificationSurvey.find('.question').hide();
                supportedVerificationSurvey.find('.thank-you-message').show();
            }

            if (supportedVerificationSurvey.length) {
                $('#answer-yes').click(function() {
                    recordResponse('Yes');
                    return false;
                });
                $('#answer-no').click(function() {
                    recordResponse('No');
                    return false;
                });
            }
        }
    };
})(window);