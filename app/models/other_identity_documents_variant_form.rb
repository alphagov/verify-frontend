class OtherIdentityDocumentsVariantForm
  include ActiveModel::Model

  attr_reader :non_uk_id_document, :smart_phone
  validate :documents_not_specified
  validate :smart_phone_not_specified_when_required

  def initialize(hash)
    @non_uk_id_document = hash[:non_uk_id_document]
    @smart_phone = hash[:smart_phone]
  end

  def selected_answers
    {
        non_uk_id_document: (@non_uk_id_document == 'true'),
        smart_phone: (@smart_phone == 'true')
    }
  end

private

  def documents_not_specified
    if !documents_specified? || !%w(true false).include?(@non_uk_id_document)
      add_no_selection_error
    end
  end

  def smart_phone_not_specified_when_required
    if documents_selected? && smartphone_not_specified?
      add_no_selection_error
    end
  end

  def add_no_selection_error
    errors.add(:base, I18n.t('hub.select_phone.errors.no_selection'))
  end

  def documents_specified?
    !non_uk_id_document.nil?
  end

  def documents_selected?
    documents_specified? && non_uk_id_document == 'true'
  end

  def smartphone_not_specified?
    smart_phone.nil? || !%w(true false).include?(@smart_phone)
  end
end
