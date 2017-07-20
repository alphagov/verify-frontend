(function(global) {
  "use strict";
  var GOVUK = global.GOVUK || {};
  var $ = global.jQuery;

  var selectProofOfAddress = {
    init: function (){
      selectProofOfAddress.$form = $('#new_select_proof_of_address_form');
      var errorMessage = selectProofOfAddress.$form.data('msg');
      if (selectProofOfAddress.$form.length === 1) {
        selectProofOfAddress.validator = selectProofOfAddress.$form.validate($.extend({}, GOVUK.validation.radiosValidation, {
          rules: {
            'select_proof_of_address_form[uk_bank_account_details]': 'required',
            'select_proof_of_address_form[debit_card]': 'required',
            'select_proof_of_address_form[credit_card]': 'required',
          },
            groups: {
                primary: 'select_proof_of_address_form[credit_card] select_proof_of_address_form[debit_card] select_proof_of_address_form[uk_bank_account_details]'
            },
          messages: {
            'select_proof_of_address_form[uk_bank_account_details]': errorMessage,
            'select_proof_of_address_form[debit_card]': errorMessage,
            'select_proof_of_address_form[credit_card]': errorMessage
          }
        }));
      }

      $('input[piwik_event_tracking]').change(function(event) {
          var target = $(event.target);
          var action = target.val() === 'true' ? 'yes' : 'no';
          var name = target.attr('piwik_event_tracking');
          _paq.push(['trackEvent', 'Evidence', action, name]);
      });
    }
  };

  GOVUK.selectProofOfAddress = selectProofOfAddress;

  global.GOVUK = GOVUK;
})(window);
