class CleverQuestions::SelectDocumentsForm
  include ActiveModel::Model

  attr_reader :driving_licence, :ni_driving_licence, :passport, :any_driving_licence, :passport_expiry
  validate :any_driving_licence_and_passport_must_be_present
  validate :driving_licence_details_present
  validate :expiry_date_present_when_passport_expired

  def initialize(select_documents_form)
    @ni_driving_licence = select_documents_form[:ni_driving_licence]
    @driving_licence = select_documents_form[:driving_licence]
    @passport = select_documents_form[:passport]
    @any_driving_licence = select_documents_form[:any_driving_licence]
    @passport_expiry = select_documents_form[:passport_expiry].nil? ? { day: '', month: '', year: '' } : select_documents_form[:passport_expiry].as_json
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence:: PHOTO_DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = (result == 'true')
      end
    end

    if passport == 'yes_expired'
      answers[:passport] = has_passport_expired_less_than_six_months
    end

    if any_driving_licence == 'false'
      answers[:driving_licence] = false
      answers[:ni_driving_licence] = false
    end
    answers
  end

  def has_passport_expired_less_than_six_months
    expiry_date = Date.new(expiry_year, expiry_month, expiry_day)
    Date.today <= expiry_date + 6.months
  end

  def further_id_information_required?
    passport == 'false' && any_driving_licence == 'false'
  end

private

  def any_driving_licence_and_passport_must_be_present
    unless any_driving_licence && passport
      add_documents_error
    end
  end

  def driving_licence_details_present
    if any_driving_licence == 'true' && no_driving_licence_details?
      add_documents_error
    end
  end

  def no_driving_licence_details?
    !(driving_licence == 'true' || ni_driving_licence == 'true')
  end

  def expiry_date_present_when_passport_expired
    if passport == 'yes_expired'
      if passport_expiry == nil || expiry_date_not_valid
        add_date_error
      end
    end
  end

  def expiry_date_not_valid
    !expiry_day.between?(1, 31) || !expiry_month.between?(1, 12) || !expiry_year.between?(1, Date.today.year)
  end

  def all_no_answers?
    document_attributes.all? { |doc| doc == 'false' }
  end

  def any_yes_answers?
    document_attributes.any? { |doc| doc == 'true' }
  end

  def add_documents_error
    errors.add(:base, I18n.t('hub.select_documents.errors.no_selection'))
  end

  def add_date_error
    errors.add(:base, I18n.t('clever_questions.hub.select_documents.errors.invalid_date'))
  end

  def document_attributes
    [passport, driving_licence, ni_driving_licence, any_driving_licence]
  end

  def expiry_day
    passport_expiry['day'].to_i
  end

  def expiry_month
    passport_expiry['month'].to_i
  end

  def expiry_year
    passport_expiry['year'].to_i
  end
end
