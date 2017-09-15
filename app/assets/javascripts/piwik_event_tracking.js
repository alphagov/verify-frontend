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
                if(hasPreviousValue) {
                    return value === 'true' ? 'Change to First Time' : 'Change to Sign In';
                }
                hasPreviousValue = true;
            }
        };
    }

    function getAppTransparencyEvent() {
      return {
        category: 'Evidence',
        name: 'App',
        getAction: function (value) {
          if (value === 'reluctant_yes'){
            return 'prefer_not_to'
          } else {
            return value === 'true' ? 'yes' : 'no'
          }
        }
      };
    }

    global.GOVUK.piwikEventsTracking = {
        init: function() {
            var piwikEvents = {
                evidence_example: getEvidenceEvent('example'),
                journey_user_type: getUserTypeEvent(),
                app_transparency: getAppTransparencyEvent()
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

