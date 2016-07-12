
(function () {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.furtherInformation = {
    init: function () {
      this.$form = $('#further-information');
      this.$form.validate();
    }
  };
}).call(this);