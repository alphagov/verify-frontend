(function () {
  'use strict';

  var root = this,
      $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.startPage = {
    init: function () {
      var $selectForm = $('#start-page-form');

      if ($selectForm.length) {
        $selectForm.validate({
          rules: {
            'selection': 'required'
          },
          messages: {
            'selection': 'Please select an option'
          }
        });
      }
    }
  };
}).call(this);
