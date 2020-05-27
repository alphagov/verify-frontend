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
    var htmlWithMarkup = '<details id="progressive_disclosure" class="govuk-details govuk-!-padding-top-6" data-module="govuk-details">' +
                          '<summary piwik_event_tracking="progressive_disclosure" class="govuk-details__summary">' +
                            '<span class="govuk-details__summary-text">What GOV.UK Verify uses these for</span>' +
                          '</summary>' +
                          '<div class="govuk-details__text">' +
                            '<p class="govuk-body">' +
                            'The companies can check your passport and driving licence against official records.' +
                            'They can also confirm your personal details by accessing information like credit records.' +
                            "This will help them be sure it's really you." +
                            '</p>' +
                            '<p class="govuk-body">' +
                            'If you only have one photo identity document (ID), you will also need to download a free app and take' +
                            'pictures of it. This will prove that the ID is yours.' +
                            '</p>' +
                            '<p class="govuk-body">' +
                            'The companies will only use your credit or debit card details as more evidence of your identity.' +
                            'They cannot see your transactions and cannot charge your account.' +
                            '</p>' +
                          '</div>' +
                        '</details>';

      beforeEach(function () {
          setUp(htmlWithMarkup);
      });

      it('should report to Piwik when evidence is selected', function () {
        $('#progressive_disclosure').click();
        expect(_paq.push).toHaveBeenCalled();

        expectLatestEntryInPiwikQueueToMatch('Engagement','Disclosure link selected','Opened');
      });
  });
});
