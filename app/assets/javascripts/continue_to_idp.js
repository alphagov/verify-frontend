(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.signin = {
    attach: function () {
      var $container = $('.js-continue-to-idp');
      $container.on('submit', '.js-idp-form', function (e) {
        var $originalForm = $(e.target);
        e.preventDefault();
        var entityId = $originalForm.find('.js-entity-id').val();
        $.ajax({
          type: 'PUT',
          url: $container.data('location'),
          contentType: "application/json",
          processData: false,
          data: JSON.stringify({ entityId: entityId }),
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

          if(response.uuid) {
            $samlForm.find('input[name=singleIdpJourneyIdentifier]').val(response.uuid);
          }
          else {
            $samlForm.find('input[name=singleIdpJourneyIdentifier]').remove();
          }
          

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
  };

  global.GOVUK = GOVUK;
})(window);
