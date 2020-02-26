class SelectPhoneForm
  include ActiveModel::Model

  attr_reader :mobile_phone, :smart_phone

  validate :mobile_phone_must_be_present_when_required, :smart_phone_not_specified_when_required
  validate :invalid_selection

  def initialize(params)
    @mobile_phone = params[:mobile_phone]
    @smart_phone = params[:smart_phone]
  end

  def selected_answers
    answers = {}
    Evidence::PHONE_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end

private

  def mobile_phone_must_be_present_when_required
    if mobile_phone.nil? && smart_phone_not_specified?
      errors.add(:mobile_phone_true, I18n.t('hub.select_phone.errors.mobile_phone'))
    end
  end

  def smart_phone_not_specified_when_required
    if has_mobile_phone? && smart_phone_not_specified?
      errors.add(:smart_phone_true, I18n.t('hub.select_phone.errors.smart_phone'))
    end
  end

  def invalid_selection
    if has_no_mobile_phone? && has_smart_phone?
      errors.add(:mobile_phone_true, I18n.t('hub.select_phone.errors.invalid_selection'))
      errors.add(:smart_phone_true, I18n.t('hub.select_phone.errors.invalid_selection'))
    end
  end

  def has_smart_phone?
    smart_phone == 'true'
  end

  def has_mobile_phone?
    mobile_phone == 'true'
  end

  def has_no_mobile_phone?
    mobile_phone == 'false'
  end

  def smart_phone_not_specified?
    smart_phone.nil?
  end
end
