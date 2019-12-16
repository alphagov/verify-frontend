describe("Feedback Form", function () {

  var formWithNoErrors =
    '<form class="feedback-form" id="feedback" novalidate="novalidate" action="/feedback" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" /><input type="hidden" name="authenticity_token" value="YNlQf7JvX07AunWY8U4SjgMd81FiyxR/3RZU15t4v/Z0GtM7bmZZn+ws/MZXgHC7HiXYs9BE2paR1mQv3XswDA==" />' +
    '<fieldset class="govuk-fieldset">' +
    '<div class="govuk-character-count" data-module="govuk-character-count" data-maxlength="3000">' +
    '<div class="govuk-form-group ">' +
    '<label class="govuk-label" for="feedback_form_what">What were you trying to do?</label>' +
    '<textarea rows="10" cols="80" class="govuk-textarea govuk-textarea--error govuk-js-character-count govuk-textarea--error" required="required" data-msg=" characters remaining (limit is 3000 characters)" data-rule-maxlength="3000" data-msg-required="Please provide details" data-msg-maxlength="This field can be up to 3000 characters" data-aria-describedby="feedback_form_what-info feedback_form_what-error" name="feedback_form[what]" id="feedback_form_what">' +
    '</textarea>' +
    '</div>' +
    '<span id="feedback_form_what-info" class="govuk-hint govuk-character-count__message" aria-live="polite">' +
    '(limit is 3000 characters)' +
    '</span>' +
    '</div>' +
    '<div class="govuk-character-count" data-module="govuk-character-count" data-maxlength="3000">' +
    '<div class="govuk-form-group ">' +
    '<label class="govuk-label" for="feedback_form_details">Please provide details of your question, problem or feedback</label>' +
    '<textarea rows="15" cols="80" class="govuk-textarea govuk-textarea--error govuk-js-character-count govuk-textarea--error" required="required" data-msg=" characters remaining (limit is 3000 characters)" data-rule-maxlength="3000" data-msg-required="Please provide details" data-msg-maxlength="This field can be up to 3000 characters" data-aria-describedby="feedback_form_details-info feedback_form_details-error" name="feedback_form[details]" id="feedback_form_details">' +
    '</textarea>' +
    '</div>' +
    '<span id="feedback_form_details-info" class="govuk-hint govuk-character-count__message" aria-live="polite">' +
    '(limit is 3000 characters)' +
    '</span>' +
    '</div>' +
    '</fieldset>' +
    '<div class="govuk-form-group ">' +
    '<fieldset class="govuk-fieldset" aria-describedby="reply-conditional-hint">' +
    '<legend class="govuk-fieldset__legend govuk-fieldset__legend--m">' +
    'Do you want a reply?' +
    '</legend>' +
    '<div class="govuk-radios govuk-radios--conditional" data-module="govuk-radios">' +
    '<div class="govuk-radios__item">' +
    '<input required="required" class="govuk-radios__input" data-aria-controls="conditional-reply_true" data-msg="Please select an option" type="radio" value="true" name="feedback_form[reply]" id="feedback_form_reply_true" />' +
    '<label class="govuk-label govuk-radios__label" for="feedback_form_reply_true">Yes</label>' +
    '</div>' +
    '<div class="govuk-radios__conditional govuk-radios__conditional--hidden"' +
    'id="conditional-reply_true">' +
    '<div class="govuk-form-group ">' +
    '<p>Leave your details below if you&#39;d like a response from GOV.UK Verify.</p>' +
    '<div class="govuk-form-group">' +
    '<label class="govuk-label" for="feedback_form_name">Name</label>' +
    '<input required="required" maxlength="255" class="govuk-input" data-msg-required="Please enter a name" size="255" type="text" name="feedback_form[name]" id="feedback_form_name" />' +
    '</div>' +
    '<div class="govuk-form-group ">' +
    '<label class="govuk-label" for="feedback_form_email">Email address</label>' +
    '<span id="event-name-hint" class="govuk-hint">' +
    'We’ll only use this to reply to your message.' +
    '</span>' +
    '<input required="required" maxlength="255" class="govuk-input" data-msg="Please enter a valid email address" size="255" type="email" name="feedback_form[email]" id="feedback_form_email" />' +
    '</div>' +
    '<p class="govuk-body govuk-!-margin-top-4">By sending this message, you consent to us using your information as detailed in the <a href="/privacy-notice#how-we-use-information">privacy notice</a>.</p>' +
    '</div>' +
    '</div>' +
    '<div class="govuk-radios__item">' +
    '<input required="required" class="govuk-radios__input" data-msg="Please select an option" type="radio" value="false" name="feedback_form[reply]" id="feedback_form_reply_false" />' +
    '<label class="govuk-label govuk-radios__label" for="feedback_form_reply_false">No</label>' +
    '</div>' +
    '</div>' +
    '</fieldset>' +
    '</div>' +
    '<input value="true" type="hidden" name="feedback_form[js_disabled]" id="feedback_form_js_disabled" />' +
    '<div class="actions">' +
    '<input type="submit" name="commit" value="Send message" class="govuk-button" />' +
    '</div>' +
    '</form>';


  var feedbackForm;
  var $dom;

  function submitForm() {
    feedbackForm.triggerHandler('submit');
  }

  function expectNoError() {
    expect(feedbackForm.find('.error, .govuk-error-message').length).toBe(0);
  }

  beforeEach(function () {
    $dom = $('<div>' + formWithNoErrors + '</div>');
    $(document.body).append($dom);
    GOVUK.validation.init();
    GOVUK.feedback.init();
    feedbackForm = GOVUK.feedback.$form;
  });

  afterEach(function () {
    $dom.remove();
  });

  it("should have no errors on initialising the form.", function () {
    expect(feedbackForm.find('.form-group-error').length).toBe(0);
  });

  it("should have errors on submit when no details entered.", function () {
    submitForm();
    expect(feedbackForm.find('.govuk-error-message').eq(0).text()).toBe('Please provide details');
    expect(feedbackForm.find('.govuk-error-message').eq(1).text()).toBe('Please provide details');
    expect(feedbackForm.find('.govuk-error-message').eq(2).text()).toBe('Please select an option');
  });

  it("should not show name and email fields on initialising the form", function () {
    expect(feedbackForm.find('#conditional-reply_true').is('.govuk-radios__conditional--hidden')).toBe(true);
  });

  it("should not validate name and email fields when no reply required", function () {
    feedbackForm.find('#feedback_form_what').val('abc');
    feedbackForm.find('#feedback_form_details').val('xyz');
    feedbackForm.find('#feedback_form_reply_false').prop('checked', true).trigger('click');
    submitForm();
    expectNoError();
  });

  it("should validate name and email fields when they are visible and unfilled", function () {
    feedbackForm.find('#feedback_form_what').val('abc');
    feedbackForm.find('#feedback_form_details').val('xyz');
    feedbackForm.find('#feedback_form_reply_true').prop('checked', true).trigger('click');
    submitForm();
    expect(feedbackForm.find('.govuk-error-message').eq(0).text()).toBe('Please enter a name');
    expect(feedbackForm.find('.govuk-error-message').eq(1).text()).toBe('Please enter a valid email address');
  });

  it("should have no errors with correct details", function () {
    feedbackForm.find('#feedback_form_what').val('abc');
    feedbackForm.find('#feedback_form_details').val('xyz');
    feedbackForm.find('#feedback_form_reply_true').prop('checked', true).trigger('click');
    feedbackForm.find('#feedback_form_name').val('John Smith');
    feedbackForm.find('#feedback_form_email').val('john@smith.com');
    submitForm();
    expectNoError();
  });

  it("should set JS disabled to false", function () {
    expect(feedbackForm.find('#feedback_form_js_disabled').val()).toBe("false");
  });
});
