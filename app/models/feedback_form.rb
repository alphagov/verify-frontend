class FeedbackForm
  include ActiveModel::Model

  attr_reader :what, :details, :reply, :name, :email, :referer, :user_agent, :js_disabled
  validate :mandatory_fields_present, :name_should_be_present,
           :what_should_be_present, :details_should_be_present
  validates :email, format: { with: /@/,
                             message: I18n.t('hub.feedback.errors.email') },
            if: :email_required?

  def initialize(hash)
    @what = hash[:what]
    @details = hash[:details]
    @name = hash[:name]
    @email = hash[:email]
    @reply = hash[:reply]
    @referer = hash[:referer]
    @user_agent = hash[:user_agent]
    @js_disabled = hash[:js_disabled]
  end

private

  def mandatory_fields_present
    if what_missing? || details_missing? || @reply.blank?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
    end
  end

  def what_should_be_present
    if what_missing?
      errors.set(:what, [I18n.t('hub.feedback.errors.details')])
    end
  end

  def details_should_be_present
    if details_missing?
      errors.set(:details, [I18n.t('hub.feedback.errors.details')])
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

  def email_required?
    if reply_required?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
    end
    reply_required?
  end

  def details_missing?
    @details.blank?
  end

  def what_missing?
    @what.blank?
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
