module IdpEligibility
  module Evidence
    PHONE_ATTRIBUTES = %i[mobile_phone smart_phone].freeze
    PHONE_ONLY_ATTRIBUTES = %i[mobile_phone].freeze
    DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence non_uk_id_document].freeze
    PHOTO_DOCUMENT_ATTRIBUTES = %i[passport driving_licence ni_driving_licence].freeze
  end
end
