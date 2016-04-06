class SelectPhoneForm
  include ActiveModel::Model

  attr_accessor :mobile_phone, :smart_phone, :landline

  PHONE_ATTRIBUTES = [:mobile_phone, :smart_phone, :landline]

  validate :check_valid

  def initialize(params)
    @mobile_phone = params[:mobile_phone]
    @smart_phone = params[:smart_phone]
    @landline = params[:landline]
  end

  def selected_evidence
    result = []
    PHONE_ATTRIBUTES.each do |attr|
      if send(attr) == 'true'
        result << attr
      end
    end
    result
  end

private

  def check_valid
    if mobile_phone != 'false' && smart_phone_not_specified?
      errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
      return
    end

    if has_no_mobile_phone? && has_smart_phone?
      errors.add(:base, I18n.t('hub.select_phone.errors.invalid_selection'))
      return
    end

    if has_no_mobile_phone? && landline_not_specified?
      errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
      return
    end
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
