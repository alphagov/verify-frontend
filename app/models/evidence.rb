module Evidence
  PHONE_ATTRIBUTES = [:mobile_phone, :smart_phone, :landline].freeze
  DOCUMENT_ATTRIBUTES = [:passport, :driving_licence, :non_uk_id_document].freeze

  ALL_ATTRIBUTES = (PHONE_ATTRIBUTES + DOCUMENT_ATTRIBUTES).freeze
end
