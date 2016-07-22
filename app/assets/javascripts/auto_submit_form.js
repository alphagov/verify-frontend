(function(global) {
  'use strict';
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.autoSubmitForm = {
    attach: function () {
      $('form.js-auto-submit').submit();
    }
  };

  global.GOVUK = GOVUK;
})(window);
