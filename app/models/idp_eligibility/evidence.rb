module IdpEligibility
  module Evidence
    PHONE_ATTRIBUTES = [:mobile_phone, :smart_phone, :landline].freeze
    DOCUMENT_ATTRIBUTES = [:passport, :driving_licence, :ni_driving_licence, :non_uk_id_document, :uk_bank_account_details, :debit_card, :credit_card].freeze

    ALL_ATTRIBUTES = (PHONE_ATTRIBUTES + DOCUMENT_ATTRIBUTES).freeze
  end
end
