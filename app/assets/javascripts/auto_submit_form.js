//= require 'jquery'

(function () {
  'use strict';
  if(!window.GOVUK) { window.GOVUK = {}; }
  window.GOVUK.autoSubmitForm = {
    attach: function () {
      $('form.js-auto-submit').submit();
    }
  };
})();
