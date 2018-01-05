(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  function stringContains(needle) {
    return function (haystack) {
      return haystack.toLowerCase().indexOf(needle.toLowerCase()) !== -1;
    }
  }

  GOVUK.chooseACountry = {
    attach: function () {
      if ($('#choose-a-country-form').length === 0) {
          return;
      }
      var options = $('#js-disabled-country-picker').find('option');

      var countryValueByText = {};
      var countryTexts = [];
      for(var i = 0; i < options.length; i++) {
        var option = options.eq(i);
        if (option.val()) {
          countryValueByText[option.text()] = option.val();
          countryTexts.push(option.text());
        }
      }

      function suggest(query, syncResults) {
        syncResults(query ? countryTexts.filter(stringContains(query)) : [])
      }

      var countryPickerElement = $('.country-picker').get(0);
      window.accessibleAutocomplete({
        element: countryPickerElement,
        minLength: 2,
        autoselect: true,
        source: suggest,
        id: 'autocomplete'
      });

      $('#choose-a-country-form').submit(function (ev) {
        var countryText = $('#autocomplete').val();
        var countryVal = countryValueByText[countryText];
        if (!countryVal) {
          $('#no-country').show();
          ev.preventDefault();
          return false;
        } else {
          $('input[name="country"]').val(countryVal);
        }
      })
    }
  };

  global.GOVUK = GOVUK;
})(window);