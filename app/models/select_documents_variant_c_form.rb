class SelectDocumentsVariantCForm
  include ActiveModel::Model

  attr_reader :has_valid_passport, :has_driving_license, :has_phone_can_app, :has_credit_card, :has_nothing
  validate :must_choose_something

  def initialize(hash)
    @has_nothing = hash[:has_nothing] == 't'
    @has_valid_passport = @has_nothing ? false : hash[:has_valid_passport] == 't'
    @has_driving_license = @has_nothing ? false :  hash[:has_driving_license] == 't'
    @has_phone_can_app = @has_nothing ? false : hash[:has_phone_can_app] == 't'
    @has_credit_card = @has_nothing ? false : hash[:has_credit_card] == 't'
  end

  def selected_answers
    answers = {}

    answers[:has_valid_passport] = @has_valid_passport
    answers[:has_driving_license] = @has_driving_license
    answers[:has_phone_can_app] = @has_phone_can_app
    answers[:has_credit_card] = @has_credit_card

    answers
  end

private

  def must_choose_something
    unless has_valid_passport || has_driving_license || has_phone_can_app || has_credit_card || has_nothing
      add_documents_error
    end
  end

  def add_documents_error
    errors.add(:base, I18n.t('hub_variant_c.select_documents.errors.no_selection'))
  end
end
