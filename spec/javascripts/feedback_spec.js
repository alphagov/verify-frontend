//= require jquery
//= require jquery.validate
//= require validation
//= require feedback

describe("Feedback Form", function () {

  var formWithNoErrors = '<form class="feedback-form" id="feedback" novalidate="novalidate" action="/feedback" accept-charset="UTF-8" method="post">' +
                           '<fieldset>' +
                             '<div class="form-group">' +
                               '<div class="form-group">' +
                                 '<label class="form-label" for="feedback_form_what">What were you trying to do?</label>' +
                                 '<textarea rows="10" cols="80" class="form-control" required="required" data-msg="Please provide details" name="feedback_form[what]" id="feedback_form_what" aria-required="true"></textarea>' +
                               '</div>' +
                             '</div>' +
                             '<div class="form-group">' +
                               '<div class="form-group">' +
                                 '<label class="form-label" for="feedback_form_details">Please provide details of your question, problem or feedback</label>' +
                                 '<textarea rows="20" cols="80" class="form-control" required="required" data-msg="Please provide details" name="feedback_form[details]" id="feedback_form_details" aria-required="true"></textarea>' +
                               '</div>' +
                             '</div>' +
                             '<div class="form-section">' +
                               '<fieldset class="inline">' +
                                 '<legend class="heading-medium">Do you want a reply?</legend>' +
                                 '<label class="block-label" onclick="" for="feedback_form_reply_true">' +
                                   '<input value="true" name="feedback_form[reply]" id="feedback_form_reply_true" type="radio">' +
                                   '<span>' +
                                     '<span class="inner"></span>' +
                                   '</span>' +
                                   'Yes' +
                                 '</label>' +
                                 '<label class="block-label" onclick="" for="feedback_form_reply_false">' +
                                   '<input value="false" name="feedback_form[reply]" id="feedback_form_reply_false" type="radio">' +
                                   '<span>' +
                                     '<span class="inner"></span>' +
                                   '</span>' +
                                   'No' +
                                 '</label>' +
                               '</fieldset>' +
                               '<div class="panel panel-border-narrow reply-fields js-hidden">' +
                                 '<p>If you’d like GOV.UK Verify to get back to you, please leave your details below.</p>' +
                                 '<div class="form-group">' +
                                   '<div class="form-group">' +
                                     '<label class="form-label" for="feedback_form_name">Name</label>' +
                                     '<input class="form-control form-control-3-4" data-msg-required="Please enter a name" name="feedback_form[name]" id="feedback_form_name" type="text">' +
                                   '</div>' +
                                 '</div>' +
                                 '<div class="form-group">' +
                                   '<div class="form-group">' +
                                     '<label class="form-label" for="feedback_form_email">' +
                                       'Email address' +
                                       '<span class="form-hint">We’ll only use this to reply to your message.</span>' +
                                     '</label>' +
                                     '<input class="form-control form-control-3-4" data-msg="Please enter a valid email address" name="feedback_form[email]" id="feedback_form_email" type="email">' +
                                   '</div>' +
                                 '</div>' +
                               '</div>' +
                             '</div>' +
                             '<input name="feedback_form[referer]" id="feedback_form_referer" type="hidden">' +
                             '<input name="feedback_form[user_agent]" id="feedback_form_user_agent" type="hidden">' +
                             '<input value="true" name="feedback_form[js_disabled]" id="feedback_form_js_disabled" type="hidden">' +
                             '<div class="actions">' +
                               '<input name="commit" value="Send message" class="button" type="submit">' +
                             '</div>' +
                           '</fieldset>' +
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
  });

  it("should not show name and email fields on initialising the form", function () {
    expect(feedbackForm.find('.reply-fields').is('.js-hidden')).toBe(true);
  });

  it("should show name and email fields when the user wants a reply", function () {
    feedbackForm.find('#feedback_form_reply_true').prop('checked', true).trigger('click');
    expect(feedbackForm.find('.reply-fields').is(':not(.js-hidden)')).toBe(true);
  });

  it("should not validate name and email fields when they are hidden", function () {
    feedbackForm.find('#feedback_form_what').val('abc');
    feedbackForm.find('#feedback_form_details').val('xyz');
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

  it("should set JS disabled to false", function () {
    expect(feedbackForm.find('#feedback_form_js_disabled').val()).toBe("false");
  });
});
