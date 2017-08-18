describe("Select Proof of Address form", function () {

  function check ($radioButton) {
    $radioButton.prop('checked', true).triggerHandler('click');
  }

  var formWithNoErrors = '' +
    '<form id="validate-proof-of-address" data-msg="Please answer all the questions">' +
    '<div id="debit_card_question" class="form-group">' +
    '<input type="radio" value="true" name="select_proof_of_address_form[debit_card]" id="select_proof_of_address_form_debit_card_true" />' +
    '<input type="radio" value="false" name="select_proof_of_address_form[debit_card]" id="select_proof_of_address_form_debit_card_false" />' +
    '</div>' +
    '<div id="credit_card_question" class="form-group">' +
    '<input type="radio" value="true" name="select_proof_of_address_form[credit_card]" id="select_proof_of_address_form_credit_card_true" />' +
    '<input type="radio" value="false" name="select_proof_of_address_form[credit_card]" id="select_proof_of_address_form_credit_card_false" />' +
    '</div>' +
    '<div id="validation-error-message-js"></div>' +
    '<div class="actions">' +
    '<input type="submit" name="commit" value="Continue" class="button" id="next-button" />' +
    '<a href="/select-proof-of-address-none">I don&#39;t have any of these documents</a>' +
    '</div>' +
    '</form>';

  var selectProofOfAddressForm;
  var $dom;
  $('html').addClass('js-enabled');

  beforeEach(function () {
    $dom = $('<div>' + formWithNoErrors + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.selectProofOfAddressNoBankAccount.init();
    selectProofOfAddressForm = GOVUK.selectProofOfAddressNoBankAccount.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(selectProofOfAddressForm.find('.form-group-error').length).toBe(0);
  });

  describe("should have no errors on submit when", function () {
    function expectNoErrors () {
      expect(selectProofOfAddressForm.children('.form-group:first').is('.form-group-error')).toBe(false);
      expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('');
    }

    it("all questions are answered with yes", function () {
      check(selectProofOfAddressForm.find('#select_proof_of_address_form_debit_card_true'));
      check(selectProofOfAddressForm.find('#select_proof_of_address_form_credit_card_true'));
      selectProofOfAddressForm.triggerHandler('submit');
      expectNoErrors();
    });

    it("all questions are answered with no", function () {
      check(selectProofOfAddressForm.find('#select_proof_of_address_form_debit_card_false'));
      check(selectProofOfAddressForm.find('#select_proof_of_address_form_credit_card_false'));
      selectProofOfAddressForm.triggerHandler('submit');
      expectNoErrors();
    });
  });

  describe("should have errors on submit when", function () {
    function expectPleaseAnswerTheQuestion () {
      expect(selectProofOfAddressForm.children('.form-group:first').is('.form-group-error')).toBe(true);
      expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('Please answer all the questions');
    }

    function expectQuestion (question) {
      return {
        toHaveError: function () {
          expect(selectProofOfAddressForm.children(question).is('.form-group-error')).toBe(true);
        },
        toNotHaveError: function () {
          expect(selectProofOfAddressForm.children(question).is('.form-group-error')).toBe(false);
        }
      };
    }

    it("no answer given", function () {
      selectProofOfAddressForm.triggerHandler('submit');
      expectPleaseAnswerTheQuestion();
    });

    describe("only debit card question", function () {
      it("answered with yes", function () {
        check(selectProofOfAddressForm.find('#select_proof_of_address_form_debit_card_true'));
        selectProofOfAddressForm.triggerHandler('submit');

        expectQuestion('#debit_card_question').toNotHaveError();
        expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('Please answer all the questions');
        expectQuestion('#credit_card_question').toHaveError();
      });

      it("answered with no", function () {
        check(selectProofOfAddressForm.find('#select_proof_of_address_form_debit_card_false'));
        selectProofOfAddressForm.triggerHandler('submit');

        expectQuestion('#debit_card_question').toNotHaveError();
        expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('Please answer all the questions');
        expectQuestion('#credit_card_question').toHaveError();
      });
    });

    describe("only credit card question", function () {
      it("answered with yes", function () {
        check(selectProofOfAddressForm.find('#select_proof_of_address_form_credit_card_true'));
        selectProofOfAddressForm.triggerHandler('submit');

        expectQuestion('#credit_card_question').toNotHaveError();
        expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('Please answer all the questions');
        expectQuestion('#debit_card_question').toHaveError();
      });

      it("answered with no", function () {
        check(selectProofOfAddressForm.find('#select_proof_of_address_form_credit_card_false'));
        selectProofOfAddressForm.triggerHandler('submit');

        expectQuestion('#credit_card_question').toNotHaveError();
        expect(selectProofOfAddressForm.find('#validation-error-message-js').text()).toBe('Please answer all the questions');
        expectQuestion('#debit_card_question').toHaveError();
      });
    });
  });
});



