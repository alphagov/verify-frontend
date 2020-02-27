class SelectDocumentsVariantCForm
  include ActiveModel::Model

  attr_accessor :has_valid_passport, :has_driving_license, :has_phone_can_app, :has_credit_card, :has_nothing
  validate :must_choose_something

  def self.from_post(hash)
    instance = self.new
    instance.has_nothing = hash[:has_nothing] == 't'
    instance.has_valid_passport = @has_nothing ? false : hash[:has_valid_passport] == 't'
    instance.has_driving_license = @has_nothing ? false :  hash[:has_driving_license] == 't'
    instance.has_phone_can_app = @has_nothing ? false : hash[:has_phone_can_app] == 't'
    instance.has_credit_card = @has_nothing ? false : hash[:has_credit_card] == 't'

    instance
  end

  def self.from_session_storage(hash)
    instance = self.new
    instance.has_valid_passport = hash['has_valid_passport']
    instance.has_driving_license = hash['has_driving_license']
    instance.has_phone_can_app = hash['has_phone_can_app']
    instance.has_credit_card = hash['has_credit_card']
    # has_nothing is set on post only – it's used for validation, but we don't pre-select
    # it when displaying the form.

    instance
  end

  def to_session_storage
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
    errors.add(:has_valid_passport, I18n.t('hub_variant_c.select_documents.errors.no_selection'))
  end
end
