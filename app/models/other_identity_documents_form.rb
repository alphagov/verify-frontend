class OtherIdentityDocumentsForm
  include ActiveModel::Model

  attr_reader :non_uk_id_document
  validate :one_must_be_present

  def initialize(hash)
    @non_uk_id_document = hash[:non_uk_id_document]
  end

  def selected_answers
    { non_uk_id_document: (@non_uk_id_document == 'true') }
  end

private

  def one_must_be_present
    unless %w(true false).include?(@non_uk_id_document)
      errors.add(:non_uk_id_document_true, I18n.t('hub.select_documents.errors.no_selection'))
    end
  end
end
