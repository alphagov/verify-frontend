describe('Analytics for select document variant c', function () {
  function setUp(html) {
      spyOn(_paq, 'push');
      setFixtures(html);
      window.GOVUK.selectDocumentsVariantC.init();
  }
  function expectLatestEntryInPiwikQueueToMatch(category, action, name) {
      var latestEntryInPiwikQueue = _paq.push.calls.mostRecent().args[0];
      expect(latestEntryInPiwikQueue[0]).toBe('trackEvent');
      expect(latestEntryInPiwikQueue[1]).toBe(category);
      expect(latestEntryInPiwikQueue[2]).toBe(action);
      expect(latestEntryInPiwikQueue[3]).toBe(name);
  };

  describe('page with disclosure', function() {
      beforeEach(function () {
          setUp('<details id="progressive_disclosure" class="govuk-details govuk-!-padding-top-6" data-module="govuk-details">' +
          '<summary piwik_event_tracking="progressive_disclosure" class="govuk-details__summary">' +
            '<span class="govuk-details__summary-text">What GOV.UK Verify uses these for</span>' +
          '</summary>' +
          '<div class="govuk-details__text">' +
          '</div>' +
        '</details>');
      });

      it('should report to Piwik when disclosure link is selected', function () {
        $('#progressive_disclosure').click();
        expect(_paq.push).toHaveBeenCalled();

        expectLatestEntryInPiwikQueueToMatch('Engagement','Disclosure link selected','Opened');
      });
  });
});
