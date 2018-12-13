module Api
  class EidasSchemeUnavailableError < StandardError
    TYPES = %w(METADATA_PROVIDER_EXCEPTION).freeze
  end
end
