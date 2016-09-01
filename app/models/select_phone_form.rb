class SelectPhoneForm
  include ActiveModel::Model

  attr_reader :mobile_phone, :smart_phone, :landline

  validate :smart_phone_not_specified_when_required
  validate :landline_not_specified_when_required, unless: :invalid_selection

  def initialize(params)
    @mobile_phone = params[:mobile_phone]
    @smart_phone = params[:smart_phone]
    @landline = params[:landline]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::PHONE_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = result == 'true'
      end
    end
    answers
  end

private

  def landline_not_specified_when_required
    if has_no_mobile_phone? && landline_not_specified?
      add_no_selection_error
    end
  end

  def smart_phone_not_specified_when_required
    if mobile_phone != 'false' && smart_phone_not_specified?
      add_no_selection_error
    end
  end

  def invalid_selection
    if has_no_mobile_phone? && has_smart_phone?
      errors.add(:base, I18n.t('hub.select_phone.errors.invalid_selection'))
    end
  end

  def add_no_selection_error
    errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
  end

  def landline_not_specified?
    landline.nil?
  end

  def has_smart_phone?
    smart_phone == 'true'
  end

  def has_no_mobile_phone?
    mobile_phone == 'false'
  end

  def smart_phone_not_specified?
    smart_phone.nil?
  end
end
