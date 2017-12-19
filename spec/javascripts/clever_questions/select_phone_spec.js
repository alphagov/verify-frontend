describe("Select Phone form", function () {

  function check($radioButton) {
    $radioButton.prop('checked', true).triggerHandler('click');
  }

  var formWithNoErrors = '' +
    '<form novalidate="novalidate" id="validate-phone" data-msg="Please answer the question">' +
      '<div class="form-group">' +
        '<input id="select_phone_form_mobile_phone_true" name="select_phone_form[mobile_phone]" value="true" type="radio">' +
        '<input id="select_phone_form_mobile_phone_false" name="select_phone_form[mobile_phone]" value="false" type="radio">' +
      '</div>' +
      '<div id="validation-error-message-js"></div>' +
      '<div class="form-group">' +
        '<input class="button" id="next-button" value="Continue" type="submit">' +
      '</div>' +
    '</form>';

  var selectPhoneForm;
  var $dom;
  $('html').addClass('js-enabled');

  beforeEach(function () {
    $dom = $('<div>' + formWithNoErrors + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.selectPhoneCleverQuestions.init();
    selectPhoneForm = GOVUK.selectPhoneCleverQuestions.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(selectPhoneForm.find('.form-group-error').length).toBe(0);
  });

  describe("should have errors on submit when", function () {
    function expectPleaseAnswerTheQuestion() {
      expect(selectPhoneForm.children('.form-group:first').is('.form-group-error')).toBe(true);
      expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('Please answer the question');
    }

    it("no answer given", function () {
      selectPhoneForm.triggerHandler('submit');
      expectPleaseAnswerTheQuestion();
    });
  });

  describe("should have no errors on submit when", function () {
    function expectNoErrors() {
      expect(selectPhoneForm.children('.form-group:first').is('.form-group-error')).toBe(false);
      expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
    }

    it("mobile answered yes ", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_true'));
      selectPhoneForm.triggerHandler('submit');
      expectNoErrors();
    });

    it("mobile answered no", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_false'));
      selectPhoneForm.triggerHandler('submit');
      expectNoErrors();
    });
  });
});
