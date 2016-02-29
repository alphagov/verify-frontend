(function () {
  "use strict";

  var root = this,
    $ = root.jQuery;

  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  root.GOVUK.signin = {
    init: function () {
    },
    attach: function () {
      $('.select-idp-form').on('submit', function (e) {
        var entityId;
        e.preventDefault();
        entityId = $(this).find('button').attr('name');
        $.ajax({
          type: "PUT",
          url: '/api/select-idp',
          contentType: "application/json",
          data: { entityId: entityId }
        }).done(function(response) {
          var $samlForm = $('#post-to-idp');
          $samlForm.prop('action', response.location);
          $samlForm.find('input[name=SAMLRequest]').val(response.samlRequest);
        }).fail(function() {
          $(this).off('submit').submit();
        });
        return false;
      });
    }
  };

}).call(this);
