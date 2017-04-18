class OtherIdentityDocumentsForm
  include ActiveModel::Model

  attr_reader :non_uk_id_document
  validate :one_must_be_present

  def initialize(hash)
    @non_uk_id_document = hash[:non_uk_id_document]
  end

  def selected_answers
    answers = {}
    IdpEligibility::Evidence::OTHER_DOCUMENT_ATTRIBUTES.each do |attr|
      result = public_send(attr)
      if %w(true false).include?(result)
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
    form_attributes.all?(&:blank?)
  end

  def form_attributes
    [non_uk_id_document]
  end

  def add_documents_error
    errors.add(:base, I18n.t('hub.select_documents.errors.no_selection'))
  end
end
