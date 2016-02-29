(function () {
  "use strict";

  var root = this,
    $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.signin = {
    init: function () {
    },
    attach: function () {
      var $selectIdpForm = $('.select-idp-form');
      $selectIdpForm.on('submit', function (e) {
        var entityId;
        e.preventDefault();
        entityId = $selectIdpForm.find('button').attr('name');
        $.ajax({
          type: "PUT",
          url: '/api/select-idp',
          contentType: "application/json",
          data: { entityId: entityId },
          timeout: 5000
        }).done(function(response) {
          var $samlForm = $('#post-to-idp');
          $samlForm.prop('action', response.location);
          $samlForm.find('input[name=SAMLRequest]').val(response.samlRequest);
          $samlForm.submit();
        }).fail(function() {
          $selectIdpForm.off('submit').submit();
        });
        return false;
      });
    }
  };

}).call(this);
