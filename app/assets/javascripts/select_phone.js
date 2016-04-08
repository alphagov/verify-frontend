(function () {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var selectPhone = {
    toggleSecondaryQuestion: function() {
      var mobilePhoneState = $('input[name="select_phone_form[mobile_phone]"]:checked').val();
      if (mobilePhoneState === undefined) {
        selectPhone.$smartphoneQuestion.add(selectPhone.$landlineQuestion)
          .addClass('js-hidden', true)
          .find('.selected').removeClass('selected').find('input').prop('checked',false);
      } else if (mobilePhoneState === 'true') {
        selectPhone.$smartphoneQuestion.removeClass('js-hidden');
        selectPhone.$landlineQuestion.addClass('js-hidden').removeClass('error')
          .find('.selected').removeClass('selected').find('input').prop('checked',false);
      } else if (mobilePhoneState === 'false') {
        selectPhone.$smartphoneQuestion.addClass('js-hidden').removeClass('error')
          .find('.selected').removeClass('selected').find('input').prop('checked',false);
        selectPhone.$landlineQuestion.removeClass('js-hidden');
      }
      selectPhone.$form.find('.form-group').removeClass('error');
      selectPhone.validator.resetForm();
    },
    init: function (){
      selectPhone.$form = $('#validate-phone');
      selectPhone.$smartphoneQuestion = $('#smartphone-question');
      selectPhone.$landlineQuestion = $('#landline-question');
      if (selectPhone.$form.length === 1) {
        selectPhone.validator = selectPhone.$form.validate({
          rules: {
            'select_phone_form[mobile_phone]': 'required',
            'select_phone_form[smart_phone]': 'required',
            'select_phone_form[landline]': 'required'
          },
          messages: {
            'select_phone_form[mobile_phone]': 'Please answer the question',
            'select_phone_form[smart_phone]': 'Please answer the question',
            'select_phone_form[landline]': 'Please answer the question'
          }
        });
        selectPhone.$form.find('#select_phone_form_mobile_phone_false,#select_phone_form_mobile_phone_true').on('click',selectPhone.toggleSecondaryQuestion);
        selectPhone.toggleSecondaryQuestion();
      }
    }
  };

  root.GOVUK.selectPhone = selectPhone;
}).call(this);
