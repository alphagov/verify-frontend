(function(global) {
    console.log('piwik_event_tracking loaded');
    function getEvidenceEvent(eventName) {
        return {
            categoryName: 'Evidence',
            eventName: eventName,
            getAction: function (value) {
                return value === 'true' ? 'yes' : 'no'
            }
        };
    };

    function getJourneyEvent() {
        return {
            categoryName: 'Journey',
            eventName: 'user_type',
            getAction: function (value) {
                return value === 'true' ? 'First Time' : 'Sign In'
            }
        }
    };

    var piwikEvents = {
        evidence_credit_card: getEvidenceEvent('credit_card'),
        evidence_debit_card: getEvidenceEvent('debit_card'),
        evidence_uk_bank_account: getEvidenceEvent('uk_bank_account_details'),
        journey_user_type: getJourneyEvent()
    };

    global.GOVUK.piwikEventsTracking = {
        init: function() {
            $('input[piwik_event_tracking]').change(function (changeEvent) {
                var target = $(changeEvent.target);
                var eventKey = target.attr('piwik_event_tracking');
                var piwikEvent = piwikEvents[eventKey];
                var action = piwikEvent.getAction(target.val());
                var categoryName = piwikEvent.categoryName;
                var eventName = piwikEvent.eventName;
                _paq.push(['trackEvent', categoryName, action, eventName]);
            });
        }
    }
})(window);

