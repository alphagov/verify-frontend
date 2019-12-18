describe('Analytics', function () {
    function setUp(html) {
        spyOn(_paq, 'push');
        setFixtures(html);
        window.GOVUK.piwikEventsTracking.init();
    }
    function expectLatestEntryInPiwikQueueToMatch(category, action, name) {
        var latestEntryInPiwikQueue = _paq.push.calls.mostRecent().args[0];
        expect(latestEntryInPiwikQueue[0]).toBe('trackEvent');
        expect(latestEntryInPiwikQueue[1]).toBe(category);
        expect(latestEntryInPiwikQueue[2]).toBe(action);
        expect(latestEntryInPiwikQueue[3]).toBe(name);
    };

    describe('on a fresh page', function() {
        var htmlWithMarkup =
            '<span id="piwik-url">http://www.fakepiwikurl.com</span>' +
            '<input type="checkbox" id="some-other-checkbox" value="false"/>' +
            '<input type="checkbox" id="tracked-evidence" value="true" piwik_event_tracking="evidence_example"/>' +
            '<input type="radio" value="true" piwik_event_tracking="journey_user_type"/>' +
            '<input type="radio" value="false" piwik_event_tracking="journey_user_type"/>';

        beforeEach(function () {
            setUp(htmlWithMarkup);
        });

        it('should report to Piwik when the user type input is changed from an initial value', function () {
            $('input[piwik_event_tracking="journey_user_type"][value="false"]').prop('checked', true).change();
            $('input[piwik_event_tracking="journey_user_type"][value="true"]').prop('checked', true).change();

            expect(_paq.push.calls.count()).toBe(2);
            expectLatestEntryInPiwikQueueToMatch('Journey', 'Change to First Time', 'user_type');
        });

        it('should report to Piwik when evidence is selected', function () {
            $('input[piwik_event_tracking="evidence_example"]').prop('checked', true).change();

            expect(_paq.push.calls.count()).toBe(2);
            expectLatestEntryInPiwikQueueToMatch('Evidence', 'yes', 'example');
        });

        it('should not report to Piwik when an input without the markup is changed', function () {
            $('#some-other-checkbox').prop('checked', true).change();

            expect(_paq.push.calls.count()).toBe(1);
        });
    });
    describe('on a page with the user_type already selected', function() {
        var htmlWithMarkup =
            '<span id="piwik-url">http://www.fakepiwikurl.com</span>' +
            '<input type="radio" value="true" piwik_event_tracking="journey_user_type"/>' +
            '<input type="radio" value="false" piwik_event_tracking="journey_user_type" checked/>';

        beforeEach(function () {
            setUp(htmlWithMarkup)
        });

        it('should report to Piwik when the user type input is changed from an initial value', function () {
            $('input[piwik_event_tracking="journey_user_type"][value="true"]').prop('checked', true).change();

            expect(_paq.push.calls.count()).toBe(2);
            expectLatestEntryInPiwikQueueToMatch('Journey', 'Change to First Time', 'user_type');
        });
    });
});
