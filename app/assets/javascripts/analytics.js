(function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
    (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
    m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
})(window,document,'script','https://www.google-analytics.com/analytics.js','ga');

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

    if(trackerUrl) {
        var siteId = $('#piwik-site-id').text();
        var customUrl = $('#piwik-custom-url').text();
        var enTitle = $('meta[name="verify|title"]').attr("content");
        var newVisit = $('#piwik-new-visit').length ? 1 : 0;

        var piwikAnalyticsQueue = [
            ['appendToTrackingUrl', 'new_visit=' + newVisit],
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
    }

    var cross_gov_ga_tracker_id = $("#cross-gov-ga-tracker-id").text();
    if (cross_gov_ga_tracker_id) {
        var domain_list = JSON.parse($("#cross-gov-ga-domain-list").text());
        ga("create", cross_gov_ga_tracker_id, "auto", "govuk_shared", {"allowLinker": true});
        ga("govuk_shared.require", "linker");
        ga("govuk_shared.linker.set", "anonymizeIp", true);
        ga("govuk_shared.linker:autoLink", domain_list, false, false);
        ga("govuk_shared.send", "pageview");
    }
})(window);
