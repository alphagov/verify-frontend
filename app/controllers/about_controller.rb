class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
  end

  def certified_companies
    reported_alternative = Cookies.parse_json(cookies[CookieNames::AB_TEST])['about_companies']
    AbTest.report('about_companies', reported_alternative, request)
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end
end
