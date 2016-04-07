//= require jquery
//= require select_phone

describe("Select Phone form", function () {

  var formWithNoErrors = '<form novalidate="novalidate" method="POST" action="/select-phone" id="validate-phone">' +
    '<div class="form-group">' +
    '<fieldset class="inline">' +
    '<legend class="form-label-bold">Do you have a mobile phone or tablet?</legend>' +
    '<label class="block-label" onclick="" for="mobile_phone-yes">' +
    '<input aria-required="true" id="mobile_phone-yes" name="select_phone_form[mobile_phone]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
    '<label class="block-label" onclick="" for="mobile_phone-no">' +
    '<input id="mobile_phone-no" name="select_phone_form[mobile_phone]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
    '</fieldset>' +
    '</div>' +
    '<div id="smartphone-question" class="form-group js-hidden">' +
    '<fieldset>' +
    '<legend class="form-label-bold">Can you install apps on your device?</legend>' +
    '<label class="block-label" onclick="" for="smart_phone-yes">' +
    '<input id="smart_phone-yes" name="select_phone_form[smart_phone]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
    '<label class="block-label" onclick="" for="smart_phone-no">' +
    '<input id="smart_phone-no" name="select_phone_form[smart_phone]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
    '<label class="block-label" onclick="" for="smart_phone-unknown">' +
    '<input id="smart_phone-unknown" name="select_phone_form[smart_phone]" value="false" type="radio"><span><span class="inner"></span></span>I don’t know</label>' +
    '</fieldset>' +
    '</div>' +
    '<div id="landline-question" class="form-group js-hidden">' +
    '<fieldset class="inline">' +
    '<legend class="form-label-bold">Do you have a landline?</legend>' +
    '<label class="block-label" onclick="" for="landline_phone-yes">' +
    '<input id="landline_phone-yes" name="select_phone_form[landline]" value="true" type="radio"><span><span class="inner"></span></span>Yes</label>' +
    '<label class="block-label" onclick="" for="landline_phone-no">' +
    '<input id="landline_phone-no" name="select_phone_form[landline]" value="false" type="radio"><span><span class="inner"></span></span>No</label>' +
    '</fieldset>' +
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
    GOVUK.selectPhone.init();
    selectPhoneForm = GOVUK.selectPhone.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(selectPhoneForm.find('.error').length).toBe(0);
  });

  it("should not initially show smartphone question.", function () {
    expect(selectPhoneForm.find('#smartphone-question').attr("class")).toContain("js-hidden");
  });

  it("should not initially show landline question.", function () {
    expect(selectPhoneForm.find('#landline-question').attr("class")).toContain("js-hidden");
  });

  it("should have errors on submit when no answer given.", function () {
    selectPhoneForm.triggerHandler('submit');
    expect(selectPhoneForm.children('.form-group:first').is('.error')).toBe(true);
    expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('Please answer the question');
  });

  //TODO Doesn't work in old frontend, will revisit once javascript is working
  //it("should have errors on submit with no mobile phone and no landline answer given.", function () {
  //  selectPhoneForm.find('#mobile_phone-no').trigger('click');
  //  selectPhoneForm.triggerHandler('submit');
  //  expect(selectPhoneForm.children('#landline-question').is('.error')).toBe(true);
  //  expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('Please answer the question');
  //});

  it("should have no errors on submit when mobile phone is chosen", function () {
    selectPhoneForm.find('#mobile_phone-yes').trigger('click');
    selectPhoneForm.find('#smart_phone-no').trigger('click');
    selectPhoneForm.triggerHandler('submit');
    expect(selectPhoneForm.children('.form-group:first').is('.error')).toBe(false);
    expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
  });

  it("should have no errors on submit when smartphone is chosen", function () {
    selectPhoneForm.find('#mobile_phone-yes').trigger('click');
    selectPhoneForm.find('#smart_phone-yes').trigger('click');
    selectPhoneForm.triggerHandler('submit');
    expect(selectPhoneForm.children('.form-group:first').is('.error')).toBe(false);
    expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
  });

  it("should have no errors on submit when landline is chosen", function () {
    selectPhoneForm.find('#mobile_phone-no').trigger('click');
    selectPhoneForm.find('#landline_phone-yes').trigger('click');
    selectPhoneForm.triggerHandler('submit');
    expect(selectPhoneForm.children('.form-group:first').is('.error')).toBe(false);
    expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
  });

  it("should have no errors on submit when no phone is chosen", function () {
    selectPhoneForm.find('#mobile_phone-no').trigger('click');
    selectPhoneForm.find('#landline_phone-no').trigger('click');
    selectPhoneForm.triggerHandler('submit');
    expect(selectPhoneForm.children('.form-group:first').is('.error')).toBe(false);
    expect(selectPhoneForm.find('#validation-error-message-js').text()).toBe('');
  });

});