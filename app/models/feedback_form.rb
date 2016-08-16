class FeedbackForm
  include ActiveModel::Model

  attr_reader :what, :details, :reply, :name, :email, :referer, :user_agent, :js_disabled
  validate :mandatory_fields_present, :name_should_be_present,
           :what_should_be_present, :details_should_be_present, :reply_should_be_present,
           :email_format_should_be_valid

  validate :length_of_what, :length_of_details, :length_of_name, :length_of_email

  LONG_TEXT_LIMIT = 3000
  SHORT_TEXT_LIMIT = 255

  def initialize(hash)
    sanitizer = Rails::Html::WhiteListSanitizer.new

    @what = sanitizer.sanitize hash[:what]
    @details = sanitizer.sanitize hash[:details]

    allowed_replies = ['true', 'false', nil]
    @reply = allowed_replies.include?(hash[:reply]) ? hash[:reply] : 'false'

    @name = sanitizer.sanitize hash[:name]
    @email = sanitizer.sanitize hash[:email]

    @referer = sanitizer.sanitize hash[:referer]
    @user_agent = sanitizer.sanitize hash[:user_agent]
    @js_disabled = hash[:js_disabled] == 'true' ? 'true' : 'false'
  end

  def data_to_submit
    ''
  end

  def reply_required?
    @reply == 'true'
  end

  def long_limit
    LONG_TEXT_LIMIT
  end

  def short_limit
    SHORT_TEXT_LIMIT
  end

  def js_enabled?
    js_disabled == 'false'
  end

private

  def mandatory_fields_present
    if what_missing? || details_missing? || @reply.blank?
      errors.add(:base, I18n.t('hub.feedback.errors.no_selection'))
    end
  end

  def reply_should_be_present
    if @reply.blank?
      errors.add(:reply, I18n.t('hub.feedback.errors.reply'))
    end
  end

  def what_should_be_present
    if what_missing?
      errors.add(:what, I18n.t('hub.feedback.errors.details'))
    end
  end

  def details_should_be_present
    if details_missing?
      errors.add(:details, I18n.t('hub.feedback.errors.details'))
    end
  end

  def name_should_be_present
    if reply_required? && name_missing?
      errors.add(:base, I18n.t('hub.feedback.errors.no_selection'))
      errors.add(:name, I18n.t('hub.feedback.errors.name'))
    end
  end

  def email_format_should_be_valid
    if reply_required? && (email_missing? || !EmailValidator.valid?(email))
      errors.add(:base, I18n.t('hub.feedback.errors.no_selection'))
      errors.add(:email, I18n.t('hub.feedback.errors.email'))
    end
  end

  def details_missing?
    @details.blank?
  end

  def what_missing?
    @what.blank?
  end

  def email_missing?
    @email.blank?
  end

  def name_missing?
    @name.blank?
  end

  def length_of_what
    if what.present? && what.length > LONG_TEXT_LIMIT
      errors.add(:what, I18n.t('hub.feedback.errors.too_long', max_length: LONG_TEXT_LIMIT))
    end
  end

  def length_of_details
    if details.present? && details.length > LONG_TEXT_LIMIT
      errors.add(:details, I18n.t('hub.feedback.errors.too_long', max_length: LONG_TEXT_LIMIT))
    end
  end

  def length_of_name
    if name.present? && name.length > SHORT_TEXT_LIMIT
      errors.add(:name, I18n.t('hub.feedback.errors.too_long', max_length: SHORT_TEXT_LIMIT))
    end
  end

  def length_of_email
    if email.present? && email.length > SHORT_TEXT_LIMIT
      errors.add(:email, I18n.t('hub.feedback.errors.too_long', max_length: SHORT_TEXT_LIMIT))
    end
  end
end
