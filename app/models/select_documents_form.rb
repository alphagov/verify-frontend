class SelectDocumentsForm
  include ActiveModel::Model

  attr_reader :driving_licence, :passport, :non_uk_id_document, :no_documents
  validate :one_must_be_present
  validate :mandatory_fields_present, unless: :all_fields_blank?
  validate :no_contradictory_inputs

  def initialize(hash)
    @driving_licence = hash[:driving_licence]
    @passport = hash[:passport]
    @non_uk_id_document = hash[:non_uk_id_document]
    @no_documents = hash[:no_documents]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if no_documents_checked?
        answers[attr] = false
      elsif %w(true false).include?(result)
        answers[attr] = (result == 'true')
      end
    end
    answers
  end

private

  def one_must_be_present
    if all_fields_blank?
      add_documents_error
    end
  end

  def all_fields_blank?
    field_attributes.all?(&:blank?)
  end

  def no_contradictory_inputs
    if no_documents_checked? && any_yes_answers?
      errors.add(:base, I18n.t('hub.select_documents.errors.invalid_selection'))
    end
  end

  # If the user hasn't selected "yes" as the answer to any of the document questions then
  # they must answer no for all of the document questions, or select "no docs"
  def mandatory_fields_present
    unless any_yes_answers? || all_no_answers? || no_documents_checked?
      add_documents_error
    end
  end

  def no_documents_checked?
    no_documents == 'true'
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

  def field_attributes
    document_attributes + [no_documents]
  end

  def document_attributes
    [passport, driving_licence, non_uk_id_document]
  end
end
