describe('Analytics', function () {
    var htmMinimalMarkup =
        '<span id="piwik-url">http://www.fakepiwikurl.com</span>' +
        '<input type="checkbox" id="some-other-checkbox" value="false"/>' +
        '<input type="checkbox" id="tracked-checkbox" value="false" piwik_event_tracking="journey_user_type"/>';
    var paqPushSpy;

    beforeEach(function () {
        spyOn(_paq, 'push');
        setFixtures(htmMinimalMarkup);
        window.GOVUK.piwikEventsTracking.init();
    });

    afterEach(function() {

    });

    it('should report to Piwik when the designated input is changed', function () {
        $('#tracked-checkbox').val(true).change();

        var latestEntryInPiwikQueue = _paq.push.calls.mostRecent().args[0];
        expect(latestEntryInPiwikQueue[0]).toBe('trackEvent');
        expect(latestEntryInPiwikQueue[1]).toBe('Journey');
        expect(latestEntryInPiwikQueue[2]).toBe('First Time');
        expect(latestEntryInPiwikQueue[3]).toBe('user_type');
    });

    it('should not report to Piwik when an input without the markup is changed', function () {
        $('#some-other-checkbox').val(true).change();

        expect(_paq.push).not.toHaveBeenCalled();
    });
});
