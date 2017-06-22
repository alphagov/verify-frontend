(function(global) {
    'use strict';
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    function setPiwikVisitorIdCookie () {
        var visitor_id = this.getVisitorId();
        GOVUK.setCookie('PIWIK_VISITOR_ID', visitor_id);
    }

    var trackerUrl = $('#piwik-url').text(),
        siteId,
        customUrl,
        piwikAnalyticsQueue,
        enTitle;

    if(!trackerUrl) {
        return;
    }

    siteId = $('#piwik-site-id').text();
    customUrl = $('#piwik-custom-url').text();
    enTitle = $('meta[name="verify|title"]').attr("content");

    piwikAnalyticsQueue = [
      ['setDocumentTitle', enTitle ],
      ['trackPageView'],
      ['enableLinkTracking'],
      [setPiwikVisitorIdCookie],
      ['setTrackerUrl', trackerUrl],
      ['setSiteId', siteId]
    ];

    if (customUrl) {
      // customUrl needs to go at the beginning of the piwik array
      piwikAnalyticsQueue.unshift(['setCustomUrl', customUrl]);
    }

    global._paq = piwikAnalyticsQueue;
})(window);
