module Api
  class EidasSchemeUnavailableError < Api::Error
    TYPES = %w(METADATA_PROVIDER_EXCEPTION).freeze
  end
end
