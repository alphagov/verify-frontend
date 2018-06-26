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
    var newVisit = $('#piwik-new-visit')

    if(newVisit.length) {
        var newVisitFlag = 1;
        // to make sure the new visit flag is used only once
        newVisit.remove();
    }
    else {
        var newVisitFlag = 0;
    }

    var piwikAnalyticsQueue = [
        ['appendToTrackingUrl', 'new_visit=' + newVisitFlag],
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
        $.each(customVariables, function(index) {
            piwikAnalyticsQueue.unshift([
                'setCustomVariable',
                customVariables[index].index,
                customVariables[index].name,
                customVariables[index].value,
                customVariables[index].scope
            ])
        });
    }

    if (customUrl) {
        // customUrl needs to go at the beginning of the piwik array
        piwikAnalyticsQueue.unshift(['setCustomUrl', customUrl]);
    }

    global._paq = piwikAnalyticsQueue;
})(window);
