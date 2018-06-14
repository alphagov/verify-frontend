(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  GOVUK.chooseCountry = {
    attach: function () {
      var $container = $('.js-redirect-to-country');
      $container.on('submit', '.js-country-form', function (e) {
        var $originalForm = $(e.target);
        e.preventDefault();
        var countrySimpleId = $originalForm.find('.js-country-simple-id').val();
        $.ajax({
          type: 'PUT',
          url: $container.data('location'),
          contentType: "application/json",
          processData: false,
          data: JSON.stringify({ country: countrySimpleId }),
          timeout: 5000
        }).done(function(response) {
          var $samlForm;
          if (!response.location) {
            throw Error('Expected response to contain location');
          }
          $samlForm = $('#post-to-country');
          $samlForm.prop('action', response.location);
          $samlForm.find('input[name=SAMLRequest]').val(response.saml_request);
          $samlForm.find('input[name=RelayState]').val(response.relay_state);
          $samlForm.find('input[name=registration]').val(response.registration);

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
