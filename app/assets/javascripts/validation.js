(function () {
  "use strict"

  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.validation = {
    init: function (){
      $.validator.setDefaults({});
    }
  };

}).call(this);
