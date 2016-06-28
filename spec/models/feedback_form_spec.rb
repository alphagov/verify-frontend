require 'rails_helper'

describe FeedbackForm do
  let(:valid_feedback_form_params) {
    { what: 'what i was doing', details: 'what happened', reply: 'false' }
  }
  context 'is not valid when' do
    short_text_limit = FeedbackForm::SHORT_TEXT_LIMIT
    long_text_limit = FeedbackForm::LONG_TEXT_LIMIT
    what_error_message = 'What ' + I18n.t('hub.feedback.errors.details')
    details_error_message = 'Details ' + I18n.t('hub.feedback.errors.details')
    name_error_message = 'Name ' + I18n.t('hub.feedback.errors.name')
    no_selection_error_message = I18n.t('hub.feedback.errors.no_selection')
    email_error_message = 'Email ' + I18n.t('hub.feedback.errors.email')
    reply_error_message = 'Reply ' + I18n.t('hub.feedback.errors.reply')
    long_length_error = I18n.t('hub.feedback.errors.too_long', max_length: long_text_limit)
    short_length_error = I18n.t('hub.feedback.errors.too_long', max_length: short_text_limit)

    it 'no answers given' do
      form = FeedbackForm.new({})

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to include no_selection_error_message
    end

    it 'reply question is not answered' do
      form = FeedbackForm.new(what: 'what i was doing', details: 'what happened')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message, reply_error_message]
    end

    it 'what were you trying to do question was not answered' do
      form = FeedbackForm.new(details: 'what happened', reply: 'false')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to include what_error_message
    end

    it 'details question was not answered' do
      form = FeedbackForm.new(what: 'what i was doing', reply: 'false')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to include details_error_message
    end

    it 'should set a character limit on what to LONG_TEXT_LIMIT characters' do
      short_enough_what = 'A' * long_text_limit
      form_with_short_enough_what = FeedbackForm.new(valid_feedback_form_params.merge(what: short_enough_what))
      expect(form_with_short_enough_what).to be_valid
      too_long_what = 'A' * (long_text_limit + 1)
      form_with_long_what = FeedbackForm.new(valid_feedback_form_params.merge(what: too_long_what))
      expect(form_with_long_what).to_not be_valid
      expect(form_with_long_what.errors.full_messages).to include 'What ' + long_length_error
    end

    it 'should set a character limit on details to LONG_TEXT_LIMIT characters' do
      short_enough_details = 'A' * long_text_limit
      form_with_short_enough_details = FeedbackForm.new(valid_feedback_form_params.merge(details: short_enough_details))
      expect(form_with_short_enough_details).to be_valid
      too_long_details = 'A' * (long_text_limit + 1)
      form_with_long_details = FeedbackForm.new(valid_feedback_form_params.merge(details: too_long_details))
      expect(form_with_long_details).to_not be_valid
      expect(form_with_long_details.errors.full_messages).to include 'Details ' + long_length_error
    end

    it 'should set a character limit on name to SHORT_TEXT_LIMIT characters' do
      short_enough_name = 'A' * short_text_limit
      form_with_short_enough_name = FeedbackForm.new(valid_feedback_form_params.merge(name: short_enough_name))
      expect(form_with_short_enough_name).to be_valid
      too_long_name = 'A' * (short_text_limit + 1)
      form_with_long_name = FeedbackForm.new(valid_feedback_form_params.merge(name: too_long_name))
      expect(form_with_long_name).to_not be_valid
      expect(form_with_long_name.errors.full_messages).to include 'Name ' + short_length_error
    end

    it 'should set a character limit on email to SHORT_TEXT_LIMIT characters' do
      short_enough_email = 'A' * (short_text_limit - 2) + '@A'
      form_with_short_enough_email = FeedbackForm.new(valid_feedback_form_params.merge(email: short_enough_email))
      expect(form_with_short_enough_email).to be_valid
      too_long_email = 'A' * (short_text_limit - 1) + '@A'
      form_with_long_email = FeedbackForm.new(valid_feedback_form_params.merge(email: too_long_email))
      expect(form_with_long_email).to_not be_valid
      expect(form_with_long_email.errors.full_messages).to include 'Email ' + short_length_error
    end

    it 'name is not provided when reply requested' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: 'true',
                              email: 'bob@smith.com')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message,
                                                name_error_message]
    end

    it 'email is not provided when reply requested' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: 'true',
                              name: 'bob smith')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message,
                                                email_error_message]
    end

    it 'invalid email format is provided when reply requested' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: 'true',
                              name: 'bob smith',
                              email: 'email')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message,
                                                email_error_message]
    end

    it 'invalid email format with missing TLD when reply requested ' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: 'true',
                              name: 'bob smith',
                              email: 'foo@bar')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message,
                                                email_error_message]
    end
  end

  context 'is valid when' do
    it 'what was I doing and details questions answered, and reply is not required' do
      form = FeedbackForm.new(what: 'what i was doing', details: 'what happened', reply: 'false')

      expect(form).to be_valid
    end

    it 'reply is requested and both name and email are provided' do
      form = FeedbackForm.new(what: 'what i was doing', details: 'what happened', reply: 'true', name: 'Bob Smith', email: 'bob@smith.com')

      expect(form).to be_valid
    end

    it 'should strip potentially malicious HTML tags' do
      form = FeedbackForm.new(what: '<script>what i was doing</script>',
                              details: '<img onerror="something malicious">what happened',
                              reply: 'true',
                              name: '<a href="javascript:something">bob smith</a>',
                              user_agent: '<script>alert("pwned")</script>',
                              referer: '<script>alert("git gud")</script>',
                              email: '<object data="nastystuff.swf">email@email.com</object>')

      expect(form.what).to eql 'what i was doing'
      expect(form.details).to eql '<img>what happened'
      expect(form.name).to eql '<a>bob smith</a>'
      expect(form.email).to eql 'email@email.com'
      expect(form.user_agent).to eql 'alert("pwned")'
      expect(form.referer).to eql 'alert("git gud")'
      expect(form).to be_valid
    end

    it 'should not allow non-boolean values for reply or js_disabled' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: '<script>true</script>',
                              js_disabled: '<script>true</script>',
                              name: 'bob smith',
                              email: 'email@email.com')
      expect(form).to be_valid
      expect(form.reply).to eql 'false'
      expect(form.js_disabled).to eql 'false'
    end
  end

  context "#js_enabled?" do
    it 'is true when js disabled is false' do
      form = FeedbackForm.new(js_disabled: 'true')
      expect(form.js_enabled?).to eql false
      form = FeedbackForm.new(js_disabled: 'false')
      expect(form.js_enabled?).to eql true
    end
  end
end
