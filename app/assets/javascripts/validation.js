(function (global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  function placeRadioErrorMessages($error, $element) {
    $error.addClass('validation-message govuk-form-group');
    $error.children('a')
      .attr({ href: '#' + $element.attr('id') })
      .on('click', function (e) {
        e.preventDefault();
        $element.focus();
      });
    $('#validation-error-message-js').append($error);
    $error.children('a').focus();
  }

  GOVUK.validation = {
    radiosValidation: {
      focusInvalid: false,
      errorClass: 'govuk-error-message',
      errorElement: 'a',
      wrapper: 'div',
      errorPlacement: placeRadioErrorMessages
    },
    init: function () {
      $.validator.setDefaults({
        errorElement: 'span',
        errorPlacement: function ($error, $element) {
          var $label = $('label[for=' + $element.attr('id') + ']');
          $error.removeClass('error');
          $error.addClass('govuk-error-message');
          $label.children('.govuk-error-message').remove();
          $label.append($error);
        },
        highlight: function (element) {
          $(element).addClass('form-control-error')
            .closest('.govuk-form-group').addClass('govuk-form-group--error');
        },
        unhighlight: function (element) {
          var formGroup = $(element).closest('.govuk-form-group');
          $(element).removeClass('form-control-error');
          formGroup.removeClass('govuk-form-group--error');
          formGroup.find('.govuk-error-message').hide();
        },
        ignore: '.js-hidden *'
      });
      $.validator.methods.email = function (value, element) {
        // This should be equivalent to the validation done by email_validator.rb (in strict mode) in the backend.
        return this.optional(element) || /^\s*([-+._\w]{1,64})@((?:[-\w]+\.)+[a-zA-Z]{2,})\s*$/.test(value);
      }
    },
    attach: function () {
      $('.js-validate').validate(GOVUK.validation.radiosValidation);
    }
  };

  global.GOVUK = GOVUK;
})(window);
