class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
  end

  def certified_companies
    ab_test_cookie = Cookies.parse_json(cookies[CookieNames::AB_TEST])['about_companies']
    alternative_name = AB_TESTS['about_companies'].alternative_name(ab_test_cookie)
    if alternative_name == ab_test_cookie
      cvar = Analytics::CustomVariable.build(:ab_test, alternative_name)
      ANALYTICS_REPORTER.report_custom_variable(request, "AB test - #{alternative_name}", cvar)
    end
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end
end
