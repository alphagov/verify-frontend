(function (global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  var selectPhone = {
    toggleSecondaryQuestion: function () {
      var mobilePhoneState = $('input[name="select_phone_form[mobile_phone]"]:checked').val();
      if (mobilePhoneState === undefined) {
        selectPhone.$smartphoneQuestion
          .addClass('js-hidden', true)
          .find('input').prop('checked', false);
      } else if (mobilePhoneState === 'true') {
        selectPhone.$smartphoneQuestion.removeClass('js-hidden');
      } else if (mobilePhoneState === 'false') {
        selectPhone.$smartphoneQuestion.addClass('js-hidden').removeClass('govuk-form-group--error')
          .find('input').prop('checked', false);
      }
      selectPhone.$form.find('.govuk-form-group').removeClass('govuk-form-group--error');
      selectPhone.validator.resetForm();
    },
    init: function () {
      selectPhone.$form = $('#validate-phone');
      selectPhone.$smartphoneQuestion = $('#smartphone-question');
      var errorMessage = selectPhone.$form.data('msg');
      if (selectPhone.$form.length === 1) {
        selectPhone.validator = selectPhone.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
          rules: {
            'select_phone_form[mobile_phone]': 'required',
            'select_phone_form[smart_phone]': () => {
              if ($('input[name="select_phone_form[mobile_phone]"]:checked').val()) {
                return 'required';
              } else {
                return 'false';
              }
            }
          },
          messages: {
            'select_phone_form[mobile_phone]': errorMessage,
            'select_phone_form[smart_phone]': errorMessage
          }
        }));
        selectPhone.$form.find('input[name="select_phone_form[mobile_phone]"]').on('click', selectPhone.toggleSecondaryQuestion);
        selectPhone.toggleSecondaryQuestion();
      }
    }
  };

  GOVUK.selectPhone = selectPhone;

  global.GOVUK = GOVUK;
})(window);
