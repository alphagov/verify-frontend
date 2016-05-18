(function () {
  "use strict";

  var root = this,
    $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.signin = {
    init: function () {
    },
    attach: function () {
      var $container = $('.js-continue-to-idp');
      $container.on('submit', '.js-idp-form', function (e) {
        var simpleId, entityId, displayName;
        var $originalForm = $(e.target);
        e.preventDefault();
        displayName = $originalForm.find('.js-display-name').val();
        entityId = $originalForm.find('.js-entity-id').val();
        simpleId = $originalForm.find('.js-simple-id').val();
        $.ajax({
          type: 'PUT',
          url: $container.data('location'),
          contentType: "application/json",
          processData: false,
          data: JSON.stringify({ entityId: entityId, displayName: displayName, simpleId: simpleId }),
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
