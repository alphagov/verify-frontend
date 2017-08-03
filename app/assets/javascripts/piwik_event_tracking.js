(function(global) {
    function getEvidenceEvent(eventName) {
        return {
            category: 'Evidence',
            name: eventName,
            getAction: function (value) {
                return value === 'true' ? 'yes' : 'no'
            }
        };
    }

    function getUserTypeEvent() {
        var hasPreviousValue = !!$('input:radio[piwik_event_tracking="journey_user_type"]:checked').val();
        return {
            category: 'Journey',
            name: 'user_type',
            getAction: function (value) {
                var result;
                if(hasPreviousValue) {
                    return value === 'true' ? 'Change to First Time' : 'Change to Sign In';
                }
                hasPreviousValue = true;
            }
        };
    }

    global.GOVUK.piwikEventsTracking = {
        init: function() {
            var piwikEvents = {
                evidence_credit_card: getEvidenceEvent('credit_card'),
                evidence_debit_card: getEvidenceEvent('debit_card'),
                evidence_uk_bank_account: getEvidenceEvent('uk_bank_account_details'),
                journey_user_type: getUserTypeEvent()
            };

            $('input[piwik_event_tracking]').change(function (changeEvent) {
                var target = $(changeEvent.target);
                var eventKey = target.attr('piwik_event_tracking');
                var piwikEvent = piwikEvents[eventKey];
                var action = piwikEvent.getAction(target.val());

                if(action) {
                    _paq.push(['trackEvent', piwikEvent.category, action, piwikEvent.name]);
                }
            });
        }
    }
})(window);

