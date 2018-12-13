module Api
  class EidasSchemeUnavailableError < StandardError
    TYPES = ['METADATA_PROVIDER_EXCEPTION'].freeze
  end
end
