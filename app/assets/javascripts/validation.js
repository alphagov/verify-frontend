(function () {
  "use strict";

  function placeRadioErrorMessages($error, $element) {
    $error.addClass('validation-message form-group');
    $error.children('a')
      .attr({ href: '#' + $element.attr('id') })
      .on('click', function (e) {
        e.preventDefault();
        $element.focus();
      });
    $('#validation-error-message-js').append($error);
    $error.children('a').focus();
  }

  var root = this,
    $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.validation = {
    radiosValidation: {
      focusInvalid: false,
      errorElement: 'a',
      wrapper: 'div',
      errorPlacement: placeRadioErrorMessages
    },
    init: function (){
      $.validator.setDefaults({
        errorElement: 'span',
        errorPlacement: function($error, $element) {
          var $label = $element.prev('label');
          $error.removeClass('error');
          $error.addClass('error-message');
          $label.children('.error-message').remove();
          $label.append($error);
        },
        highlight: function(element) {
          $(element).closest('.form-group').addClass('error');
        },
        unhighlight: function(element) {
          $(element).closest('.form-group').removeClass('error');
        },
        ignore: '.js-hidden *'
      });
    },
    attach: function () {
      $('.js-validate').validate(GOVUK.validation.radiosValidation);
    }
  };

}).call(this);
