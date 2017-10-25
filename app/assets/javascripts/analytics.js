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

    var trackerUrl = $('#piwik-url').text();

    if(!trackerUrl) {
        return;
    }

    var siteId = $('#piwik-site-id').text();
    var customUrl = $('#piwik-custom-url').text();
    var enTitle = $('meta[name="verify|title"]').attr("content");

    var piwikAnalyticsQueue = [
        ['setUserId', getPiwikVisitorIdCookie()],
        ['setDocumentTitle', enTitle ],
        ['trackPageView'],
        ['enableLinkTracking'],
        ['setTrackerUrl', trackerUrl],
        ['setSiteId', siteId]
    ];

    var customVariablesString = $('#piwik-custom-variables').text();
    if (customVariablesString) {
        var customVariables = JSON.parse(customVariablesString);
        customVariables.forEach(function(customVariable) {
            piwikAnalyticsQueue.unshift([
                'setCustomVariable',
                customVariable.index,
                customVariable.name,
                customVariable.value,
                customVariable.scope
            ])
        })
    }

    if (customUrl) {
        // customUrl needs to go at the beginning of the piwik array
        piwikAnalyticsQueue.unshift(['setCustomUrl', customUrl]);
    }

    global._paq = piwikAnalyticsQueue;
})(window);
