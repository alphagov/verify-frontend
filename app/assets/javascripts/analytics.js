(function (global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  function generateEightHexadecimalDigits() {
    return Math.random().toString(16).substr(2, 8);
  }

  function getPiwikVisitorIdCookie() {
    var userId = GOVUK.getCookie("PIWIK_USER_ID");
    if (!userId) {
      userId = generateEightHexadecimalDigits() + generateEightHexadecimalDigits();
      GOVUK.setCookie("PIWIK_USER_ID", userId);
    }
    return userId;
  }

  var trackerUrl = $("#piwik-url").text();

  if (trackerUrl) {
    var siteId = $("#piwik-site-id").text();
    var customUrl = $("#piwik-custom-url").text();
    var enTitle = $("meta[name='verify|title']").attr("content");
    var newVisit = $("#piwik-new-visit").length ? 1 : 0;

    var piwikAnalyticsQueue = [
      ["appendToTrackingUrl", "new_visit=" + newVisit],
      ["setDocumentTitle", enTitle],
      ["trackPageView"],
      ["enableLinkTracking"],
      ["setTrackerUrl", trackerUrl],
      ["setSiteId", siteId]
    ];

    var customVariablesString = $("#piwik-custom-variables").text();
    if (customVariablesString) {
      var customVariables = JSON.parse(customVariablesString);
      $.each(customVariables, function (index) {
        piwikAnalyticsQueue.unshift([
          "setCustomVariable",
          customVariables[index].index,
          customVariables[index].name,
          customVariables[index].value,
          customVariables[index].scope
        ]);
      });
    }

    if (customUrl) {
      // customUrl needs to go at the beginning of the piwik array
      piwikAnalyticsQueue.unshift(["setCustomUrl", customUrl]);
    }

    global._paq = piwikAnalyticsQueue;
  }

  var crossGovGaTrackerId = $("#cross-gov-ga-tracker-id").text();
  if (crossGovGaTrackerId) {
    var domainList = JSON.parse($("#cross-gov-ga-domain-list").text());
    window.ga("create", crossGovGaTrackerId, "auto", "govuk_shared", {"allowLinker": true});
    window.ga("govuk_shared.require", "linker");
    window.ga("govuk_shared.linker.set", "anonymizeIp", true);
    window.ga("govuk_shared.linker:autoLink", domainList, false, true);
    window.ga("govuk_shared.send", "pageview");
  }
})(window);
