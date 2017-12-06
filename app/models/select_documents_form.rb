class SelectDocumentsForm
  include ActiveModel::Model

  attr_reader :driving_licence, :ni_driving_licence, :passport, :any_driving_licence
  validate :any_driving_licence_and_passport_must_be_present
  validate :driving_licence_details_present

  def initialize(hash)
    @driving_licence = hash[:driving_licence]
    @passport = hash[:passport]
    @any_driving_licence = hash[:any_driving_licence]
  end

  def selected_answers
    answers = {}
    Evidence:: PHOTO_DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
        answers[attr] = (result == 'true')
      end
    end
    if any_driving_licence == 'true'
      answers[:driving_licence] = (driving_licence == 'great_britain')
      answers[:ni_driving_licence] = (driving_licence == 'northern_ireland')
    end
    if any_driving_licence == 'false'
      answers[:driving_licence] = false
      answers[:ni_driving_licence] = false
    end
    answers
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
    !(driving_licence == 'great_britain' || driving_licence == 'northern_ireland')
  end

  def add_documents_error
    errors.add(:base, I18n.t('hub.select_documents.errors.no_selection'))
  end
end
