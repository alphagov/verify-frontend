(function(global) {
    'use strict';
    var GOVUK = global.GOVUK || {};
    var $ = global.jQuery;

    function generateEightHexadecimalDigits() {
        return Math.random().toString(16).substr(2, 8);
    }

    function getPiwikVisitorIdCookie() {
        var userId = GOVUK.getCookie('PIWIK_USER_ID');
        if (!userId) {
            userId = generateEightHexadecimalDigits() + generateEightHexadecimalDigits();
            GOVUK.setCookie('PIWIK_USER_ID', userId);
        }
        return userId;
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
        ['setUserId', getPiwikVisitorIdCookie()],
        ['setDocumentTitle', enTitle ],
        ['trackPageView'],
        ['enableLinkTracking'],
        ['setTrackerUrl', trackerUrl],
        ['setSiteId', siteId]
    ];

    if (customUrl) {
        // customUrl needs to go at the beginning of the piwik array
        piwikAnalyticsQueue.unshift(['setCustomUrl', customUrl]);
    }

    global._paq = piwikAnalyticsQueue;
})(window);
