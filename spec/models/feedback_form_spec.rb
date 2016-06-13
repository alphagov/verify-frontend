require 'rails_helper'

describe FeedbackForm do
  context 'is not valid when' do
    what_error_message = 'What ' + I18n.t('hub.feedback.errors.details')
    details_error_message = 'Details ' + I18n.t('hub.feedback.errors.details')
    name_error_message = 'Name ' + I18n.t('hub.feedback.errors.name')
    no_selection_error_message = I18n.t('hub.feedback.errors.no_selection')
    email_error_message = 'Email ' + I18n.t('hub.feedback.errors.email')

    it 'no answers given' do
      form = FeedbackForm.new({})

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to include no_selection_error_message
    end

    it 'reply question is not answered' do
      form = FeedbackForm.new(what: 'what i was doing', details: 'what happened')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql [no_selection_error_message]
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

    it 'invalid email format is not provided when reply requested' do
      form = FeedbackForm.new(what: 'what i was doing',
                              details: 'what happened',
                              reply: 'true',
                              name: 'bob smith',
                              email: 'email')

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
  end
end
