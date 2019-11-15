(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.furtherInformation = {
    init: function () {
      this.$form = $('#further-information');
      this.$form.validate();
    }
  };

  global.GOVUK = GOVUK;
})(window);
