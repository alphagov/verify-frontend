(function() {
  "use strict";
  var root = this,
    $ = root.jQuery;
  if(typeof root.GOVUK === 'undefined') { root.GOVUK = {}; }

  var chooseACertifiedCompany = {
    init: function() {
      var $nonMatchingIdps = $('#non-matching-idps'),
        $warning = $('#non-matching-idps-warning'),
        $showCompanies = $warning.find('a');

      $showCompanies.on('click', function(event) {
        event.preventDefault();
        $warning.addClass('hidden').removeClass('js-show');
        $nonMatchingIdps.removeClass('js-hidden');
      });
    }
  };

  root.GOVUK.chooseACertifiedCompany = chooseACertifiedCompany;
}).call(this);
