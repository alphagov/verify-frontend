class FeedbackForm
  include ActiveModel::Model

  attr_reader :what, :details, :reply, :name, :email, :referer, :user_agent, :js_disabled
  validate :mandatory_fields_present, :name_should_be_present,
           :what_should_be_present, :details_should_be_present, :reply_should_be_present,
           :email_format_should_be_valid, :email_should_be_present

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

  private

  def mandatory_fields_present
    if what_missing? || details_missing? || @reply.blank?
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
    end
  end

  def reply_should_be_present
    if @reply.blank?
      errors.set(:reply, [I18n.t('hub.feedback.errors.reply')])
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

  def email_format_should_be_valid
    if reply_required? && @email && !@email.match(/@/)
      errors.set(:base, [I18n.t('hub.feedback.errors.no_selection')])
      errors.set(:email, [I18n.t('hub.feedback.errors.email')])
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
end
