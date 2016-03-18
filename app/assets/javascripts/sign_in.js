(function () {
  "use strict";

  var root = this,
    $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.signin = {
    init: function () {
    },
    attach: function () {
      var $container = $('.js-idp-option-container')
      $container.on('submit', '.idp-option', function (e) {
        var entityId;
        var $originalForm = $(e.target);
        e.preventDefault();
        entityId = $originalForm.find('button').attr('name');
        $.ajax({
          type: 'PUT',
          url: '/select-idp',
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
          $samlForm.submit();
        }).fail(function() {
          $container.off('submit');
          $originalForm.submit();
        });
        return false;
      });
    }
  };

}).call(this);
