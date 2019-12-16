describe("Select Phone form", function () {

  function check($radioButton) {
    $radioButton.prop('checked', true).triggerHandler('click');
  }

  var formWithNoErrors = '<form id="validate-phone" class="select-phone-form" novalidate="novalidate" data-msg="Please answer the question" action="/select-phone" accept-charset="UTF-8" method="post"> <input name="utf8" type="hidden" value="&#x2713;" /> <input type="hidden" name="authenticity_token" value="imRopCxIjkN2UyJtbOjK/0S3zhCbGafiJQ76d7FOyhSddw8d5aaTsiesDFOcE9C8/A9ylJuGQdh/eWhn0np0Pw==" />' +
    ' <div class="govuk-form-group govuk-form-group--error">' +
    ' <fieldset class="govuk-fieldset" aria-describedby="how-contacted-conditional-hint">' +
    ' <legend class="govuk-fieldset__legend govuk-fieldset__legend--xl">' +
    ' <h2 class="govuk-heading-m govuk-visually-hidden">Do you have a mobile phone or tablet?</h2>' +
    ' </legend>' +
    ' <div class="govuk-radios govuk-radios--conditional" data-module="govuk-radios">' +
    ' <div class="govuk-radios__item">' +
    ' <input class="govuk-radios__input" data-aria-controls="conditional-mobile_phone_true" type="radio" value="true" name="select_phone_form[mobile_phone]" id="select_phone_form_mobile_phone_true" />' +
    ' <label class="govuk-label govuk-radios__label" for="select_phone_form_mobile_phone_true">Yes</label>' +
    ' </div>' +
    ' <div class="govuk-radios__conditional govuk-radios__conditional--hidden" id="conditional-mobile_phone_true">' +
    ' <div class="govuk-form-group">' +
    ' <fieldset class="govuk-fieldset">' +
    ' <fieldset class="govuk-fieldset">' +
    ' <legend class="govuk-fieldset__legend govuk-fieldset__legend--xl">' +
    ' <h2 class="govuk-heading-s">Can you install apps on your device?</h2>' +
    ' </legend>' +
    ' <div class="govuk-radios">' +
    ' <div class="govuk-radios__item">' +
    ' <input class="govuk-radios__input" type="radio" value="true" name="select_phone_form[smart_phone]" id="select_phone_form_smart_phone_true" />' +
    ' <label class="govuk-label govuk-radios__label" for="select_phone_form_smart_phone_true">Yes</label>' +
    ' </div>' +
    ' <div class="govuk-radios__item">' +
    ' <input class="govuk-radios__input" type="radio" value="false" name="select_phone_form[smart_phone]" id="select_phone_form_smart_phone_false" />' +
    ' <label class="govuk-label govuk-radios__label" for="select_phone_form_smart_phone_false">No</label>' +
    ' </div>' +
    ' <div class="govuk-radios__item">' +
    ' <input class="govuk-radios__input" type="radio" value="do_not_know" name="select_phone_form[smart_phone]" id="select_phone_form_smart_phone_do_not_know" />' +
    ' <label class="govuk-label govuk-radios__label" for="select_phone_form_smart_phone_do_not_know">I don’t know</label>' +
    ' </div>' +
    ' </div>' +
    ' </fieldset>' +
    ' </div>' +
    ' </div>' +
    ' <div class="govuk-radios__item">' +
    ' <input class="govuk-radios__input" type="radio" value="false" name="select_phone_form[mobile_phone]" id="select_phone_form_mobile_phone_false" />' +
    ' <label class="govuk-label govuk-radios__label" for="select_phone_form_mobile_phone_false">No</label>' +
    ' </div>' +
    ' </div>' +
    ' </fieldset>' +
    ' </div>' +
    ' <div id="validation-error-message-js"></div>' +
    ' <div class="actions">' +
    ' <input type="submit" name="commit" value="Continue" class="govuk-button" id="next-button" />' +
    ' </div>' +
    ' </form>';

  var selectPhoneForm;
  var $dom;
  $('html').addClass('js-enabled');

  beforeEach(function () {
    $dom = $('<div>' + formWithNoErrors + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.selectPhone.init();
    selectPhoneForm = GOVUK.selectPhone.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(selectPhoneForm.find('.govuk-form-group--error').length).toBe(0);
  });

  describe("should have errors on submit when", function () {
    function expectPleaseAnswerTheQuestion() {
      expect(selectPhoneForm.children('.govuk-form-group:first').is('.govuk-form-group--error')).toBe(true);
      expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('Please answer the question');
    }

    it("no answer given", function () {
      selectPhoneForm.triggerHandler('submit');
      expectPleaseAnswerTheQuestion();
    });

    it("mobile answered yes", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_true'));
      selectPhoneForm.triggerHandler('submit');
      console.log(GOVUK.selectPhone.$form.text());
      expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('Please answer the question');
      expect($('#conditional-mobile_phone_true').children().is('.govuk-form-group--error')).toBe(true);
    });
  });

  describe("should have no errors on submit when", function () {
    function expectNoErrors() {
      expect(selectPhoneForm.children('.govuk-form-group:first').is('.govuk-form-group--error')).toBe(false);
      expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
    }

    it("mobile answered yes and smartphone answered no", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_true'));
      check(selectPhoneForm.find('#select_phone_form_smart_phone_false'));
      selectPhoneForm.triggerHandler('submit');
      expectNoErrors();
    });

    it("mobile answered yes and smartphone answered dont know", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_true'));
      check(selectPhoneForm.find('#select_phone_form_smart_phone_do_not_know'));
      selectPhoneForm.triggerHandler('submit');
      expectNoErrors();
    });

    it("mobile answered yes and smartphone answered yes", function () {
      check(selectPhoneForm.find('#select_phone_form_mobile_phone_true'));
      check(selectPhoneForm.find('#select_phone_form_smart_phone_true'));
      selectPhoneForm.triggerHandler('submit');
      expectNoErrors();
    });
  });
});
