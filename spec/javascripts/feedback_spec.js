describe("Feedback Form", function () {

  var formWithNoErrors =
    '<form id="feedback" novalidate="novalidate" action="/feedback" method="post">' +
      '<label for="feedback_form_what">What were you trying to do?</label>' +
      '<textarea required="required" data-msg=" characters remaining" data-msg-required="Please provide details" data-rule-maxlength="42" name="feedback_form[what]" id="feedback_form_what" class="counted"></textarea>' +
      '<span id="feedback_form_what_counter"></span>' +
      '<label for="feedback_form_details">Please provide details of your question, problem or feedback</label>' +
      '<textarea required="required" data-msg="Please provide details" name="feedback_form[details]" id="feedback_form_details" class="counter"></textarea>' +
      '<fieldset class="form-group">' +
        '<legend>Do you want a reply?</legend>' +
        '<label for="feedback_form_reply_true">' +
          '<input required data-msg="Please select an option" value="true" name="feedback_form[reply]" id="feedback_form_reply_true" type="radio">' +
          'Yes' +
        '</label>' +
        '<label for="feedback_form_reply_false">' +
          '<input required data-msg="Please select an option" value="false" name="feedback_form[reply]" id="feedback_form_reply_false" type="radio">' +
          'No' +
        '</label>' +
      '</fieldset>' +
      '<div class="reply-fields js-hidden">' +
        '<label for="feedback_form_name">Name</label>' +
        '<input required data-msg="Please enter a name" name="feedback_form[name]" id="feedback_form_name" type="text">' +
        '<label for="feedback_form_email">' +
          'Email address' +
        '</label>' +
        '<input required data-msg="Please enter a valid email address" name="feedback_form[email]" id="feedback_form_email" type="email">' +
      '</div>' +
      '<input name="feedback_form[referer]" id="feedback_form_referer" type="hidden">' +
      '<input name="feedback_form[user_agent]" id="feedback_form_user_agent" type="hidden">' +
      '<input value="true" name="feedback_form[js_disabled]" id="feedback_form_js_disabled" type="hidden">' +
      '<input name="commit" value="Send message" type="submit">' +
    '</form>';


  var feedbackForm;
  var $dom;

  function submitForm() {
    feedbackForm.triggerHandler('submit');
  }

  function expectNoError() {
    expect(feedbackForm.find('.error, .error-message').length).toBe(0);
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
    expect(feedbackForm.find('.error').length).toBe(0);
  });

  it("should have errors on submit when no details entered.", function () {
    submitForm();
    expect(feedbackForm.find('.error-message').eq(0).text()).toBe('Please provide details');
    expect(feedbackForm.find('.error-message').eq(1).text()).toBe('Please provide details');
    expect(feedbackForm.find('.error-message').eq(2).text()).toBe('Please select an option');
  });

  it("should not show name and email fields on initialising the form", function () {
    expect(feedbackForm.find('.reply-fields').is('.js-hidden')).toBe(true);
  });

  it("should show name and email fields when the user wants a reply", function () {
    feedbackForm.find('#feedback_form_reply_true').prop('checked', true).trigger('click');
    expect(feedbackForm.find('.reply-fields').is(':not(.js-hidden)')).toBe(true);
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
    expect(feedbackForm.find('.error-message').eq(0).text()).toBe('Please enter a name');
    expect(feedbackForm.find('.error-message').eq(1).text()).toBe('Please enter a valid email address');
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

  it("should count characters", function () {
    var textarea = feedbackForm.find('#feedback_form_what');
    textarea.triggerHandler('txtinput');
    expect(feedbackForm.find('#feedback_form_what_counter').text()).toBe('42 characters remaining');
    textarea.val('This text is way more than 42 characters long!');
    textarea.triggerHandler('txtinput');
    expect(feedbackForm.find('#feedback_form_what_counter').text()).toBe('-4 characters remaining');
  });

  it("should set JS disabled to false", function () {
    expect(feedbackForm.find('#feedback_form_js_disabled').val()).toBe("false");
  });
});
