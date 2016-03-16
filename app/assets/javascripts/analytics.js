(function () {
   'use strict';
    var url = $('#piwik-url').text();
    if(!url) {
        return;
    }
    var siteId = $('#piwik-site-id').text();
    var _paq = [];
    _paq.push(['setDocumentTitle', document.title ]);
    _paq.push(["trackPageView"]);
    _paq.push(["enableLinkTracking"]);
    _paq.push([ function() {
        var visitor_id = this.getVisitorId();
        GOVUK.setCookie("PIWIK_VISITOR_ID", visitor_id);
    }]);
    _paq.push(["setTrackerUrl", url]);
    _paq.push(["setSiteId", siteId]);
    window._paq = _paq;
})();