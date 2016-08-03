class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
  end

  def certified_companies
    alternative_name = AB_TEST.alternative_name(cookies[CookieNames::AB_TEST])
    if alternative_name == cookies[CookieNames::AB_TEST]
      cvar = Analytics::CustomVariable.build(:ab_test, alternative_name)
      ANALYTICS_REPORTER.report_custom_variable(request, "AB test - #{alternative_name}", cvar)
    end
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end
end
