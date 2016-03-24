class SelectDocumentsForm
  include ActiveModel::Model

  attr_reader :uk_driving_licence, :uk_passport, :foreign_id, :no_docs
  validate :one_must_be_present
  validate :mandatory_fields_present, unless: :all_fields_blank?
  validate :no_contradictory_inputs

  def initialize(hash)
    @uk_driving_licence = hash[:uk_driving_licence]
    @uk_passport = hash[:uk_passport]
    @foreign_id = hash[:foreign_id]
    @no_docs = hash[:no_docs]
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
    if no_docs_checked? && any_yes_answers?
      errors.add(:base, 'Please check your selection')
    end
  end

  # If the user hasn't selected "yes" as the answer to any of the document questions then
  # they must answer no for all of the document questions, or select "no docs"
  def mandatory_fields_present
    unless any_yes_answers? || all_no_answers? || no_docs_checked?
      add_documents_error
    end
  end

  def no_docs_checked?
    no_docs == 'true'
  end

  def all_no_answers?
    document_attributes.all? { |doc| doc == 'false' }
  end

  def any_yes_answers?
    document_attributes.any? { |doc| doc == 'true' }
  end

  def add_documents_error
    errors.add(:base, 'Please select the documents you have')
  end

  def field_attributes
    document_attributes + [no_docs]
  end

  def document_attributes
    [uk_passport, uk_driving_licence, foreign_id]
  end
end
