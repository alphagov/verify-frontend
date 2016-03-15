(function () {
   'use strict';

    var _paq = [];
    var url = $('#piwik-url').text();
    _paq.push(['setDocumentTitle', document.title ]);
    _paq.push(["trackPageView"]);
    _paq.push(["enableLinkTracking"]);
    _paq.push([ function() {
        var visitor_id = this.getVisitorId();
        GOVUK.setCookie("PIWIK_VISITOR_ID", visitor_id);
    }]);
    _paq.push(["setTrackerUrl", url]);
    _paq.push(["setSiteId", '1']);
    window._paq = _paq;
})();