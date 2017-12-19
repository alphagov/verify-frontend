(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;
  var selectPhone = {
    init: function (){
      selectPhone.$form = $('#validate-phone');
      var errorMessage = selectPhone.$form.data('msg');
      if (selectPhone.$form.length === 1) {
        selectPhone.validator = selectPhone.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
          rules: {
            'select_phone_form[mobile_phone]': 'required'
          },
          messages: {
            'select_phone_form[mobile_phone]': errorMessage
          }
        }));
        selectPhone.$form.find('input[name="select_phone_form[mobile_phone]"]').on('click',selectPhone.toggleSecondaryQuestion);
      }
    }
  };

  GOVUK.selectPhoneCleverQuestions = selectPhone;

  global.GOVUK = GOVUK;
})(window);
