(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.autoSubmitForm = {
    attach: function () {
      $("#continue-button").click();
    }
  };

  global.GOVUK = GOVUK;
})(window);
