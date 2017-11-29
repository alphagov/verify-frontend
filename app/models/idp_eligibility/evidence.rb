module IdpEligibility
  module Evidence
    PHONE_ATTRIBUTES = %i[mobile_phone smart_phone landline].freeze
    PHONE_ONLY_ATTRIBUTES = %i[mobile_phone].freeze
    SMARTPHONE_ONLY_ATTRIBUTES = %i[smart_phone].freeze
    DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence non_uk_id_document].freeze
    PHOTO_DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence].freeze
    ADDRESS_DOCUMENT_ATTRIBUTES = %i[uk_bank_account_details debit_card credit_card].freeze

    ALL_ATTRIBUTES = (PHONE_ATTRIBUTES + DOCUMENT_ATTRIBUTES).freeze
  end

  module EvidenceVariant
    PHONE_ATTRIBUTES = %i[mobile_phone smart_phone landline].freeze
    DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence non_uk_id_document].freeze
    PHOTO_DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence].freeze
    ADDRESS_DOCUMENT_ATTRIBUTES = %i[debit_card credit_card].freeze

    ALL_ATTRIBUTES = (PHONE_ATTRIBUTES + DOCUMENT_ATTRIBUTES).freeze
  end
end
