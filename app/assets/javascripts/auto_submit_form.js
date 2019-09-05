(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.autoSubmitForm = {
    attach: function () {
      // Using button.click() rather than form.submit() due to Google Analytic cross domain tracking code that can only
      // execute if the submit button is clicked.
      $("#continue-button").click();
    }
  };

  global.GOVUK = GOVUK;
})(window);
