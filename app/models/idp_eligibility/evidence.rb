module IdpEligibility
  module Evidence
    PHONE_ATTRIBUTES = [:mobile_phone, :smart_phone, :landline].freeze
    DOCUMENT_ATTRIBUTES = [:passport, :driving_licence, :ni_driving_licence, :non_uk_id_document].freeze
    PHOTO_DOCUMENT_ATTRIBUTES = [:passport, :driving_licence, :ni_driving_licence].freeze

    ALL_ATTRIBUTES = (PHONE_ATTRIBUTES + DOCUMENT_ATTRIBUTES).freeze
  end
end
