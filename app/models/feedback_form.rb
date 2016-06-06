class FeedbackForm
  include ActiveModel::Model

  attr_reader :what, :details, :reply, :name, :email, :referer, :user_agent, :js_disabled
  validate :mandatory_fields_present, :name_should_be_present, :email_should_be_present

  def initialize(hash)
    @what = hash[:what]
    @details = hash[:details]
    @name = hash[:name]
    @email = hash[:email]
    @reply = hash[:reply]
  end

private

  def mandatory_fields_present
    if @what.blank? || @details.blank?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
    end
  end

  def name_should_be_present
    if reply_required? && name_missing?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
      errors.set(:name, [I18n.t('hub.feedback.errors.name')])
    end
  end

  def email_should_be_present
    if reply_required? && email_missing?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
      errors.set(:email, [I18n.t('hub.feedback.errors.email')])
    end
  end

  def reply_required?
    @reply == 'true'
  end

  def email_missing?
    @email.blank?
  end

  def name_missing?
    @name.blank?
  end
end
