# frozen_string_literal: true

module JourneyType
  EIDAS = "EIDAS"
  VERIFY = "VERIFY"

  VALID_JOURNEY_TYPES = [EIDAS, VERIFY].freeze
  module Verify
    SIGN_IN = "sign-in"
    REGISTRATION = "registration"
    SIGN_IN_LAST_SUCCESSFUL_IDP = "sign-in-last-successful-idp"
    SINGLE_IDP = "single-idp"
    RESUMING = "resuming"
  end
end
