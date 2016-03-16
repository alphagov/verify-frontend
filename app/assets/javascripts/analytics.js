(function () {
   'use strict';
    var trackerUrl = $('#piwik-url').text();
    if(!trackerUrl) {
        return;
    }
    var siteId = $('#piwik-site-id').text();
    var customUrl = $('#piwik-custom-url').text();
    var _paq = [];
    _paq.push(['setDocumentTitle', document.title ]);
    if(customUrl) {
        _paq.push(['setCustomUrl', customUrl]);
    }
    _paq.push(["trackPageView"]);
    _paq.push(["enableLinkTracking"]);
    _paq.push([ function() {
        var visitor_id = this.getVisitorId();
        GOVUK.setCookie("PIWIK_VISITOR_ID", visitor_id);
    }]);
    _paq.push(["setTrackerUrl", trackerUrl]);
    _paq.push(["setSiteId", siteId]);
    window._paq = _paq;
})();
