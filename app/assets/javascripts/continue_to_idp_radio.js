(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.signinRadio = {
    attach: function () {
      var $container = $('.js-continue-to-idp-radio');
      if($container.length == 1){
        GOVUK.signinRadio.$form = $('#choose-a-certified-company-form');
        var errorMessage = GOVUK.signinRadio.$form.data('msg');

        GOVUK.signinRadio.validator = GOVUK.signinRadio.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
          rules: {
            'entity_id': 'required'
          },
          messages: {
            'entity_id': errorMessage
          }
        }));

        $container.on('submit', '.js-idp-form-radio', function (e) {
          var $originalForm = $(e.target);
          e.preventDefault();
          var entityId = $originalForm.find('input[name=entity_id]:checked').val();
          $.ajax({
            type: 'PUT',
            url: $container.data('location'),
            contentType: "application/json",
            processData: false,
            data: JSON.stringify({ entity_id: entityId }),
            timeout: 5000
          }).done(function(response) {
            var $samlForm;
            if (!response.location) {
              throw Error('Expected response to contain location');
            }
            $samlForm = $('#post-to-idp');
            $samlForm.prop('action', response.location);
            $samlForm.find('input[name=SAMLRequest]').val(response.saml_request);
            $samlForm.find('input[name=RelayState]').val(response.relay_state);
            $samlForm.find('input[name=registration]').val(response.registration);

            if (response.hints) {
              $.each(response.hints, function (index, hint) {
                $samlForm.append($('<input name="hint" type="hidden">').val(hint));
              });
            }

            if (response.language_hint) {
              $samlForm.append($('<input name="language" type="hidden">').val(response.language_hint));
            }

            $samlForm.submit();
          }).fail(function() {
            $container.off('submit');
            $originalForm.submit();
          });
          return false;
        });
      }
    }
  };

  global.GOVUK = GOVUK;
})(window);
