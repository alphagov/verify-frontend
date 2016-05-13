class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction_simple_id,
      request
    )
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers)
  end

  def choosing_a_company
  end

private

  def federation_info
    SESSION_PROXY.federation_info_for_session(cookies)
  end

  def identity_providers
    SESSION_PROXY.identity_providers(cookies)
  end
end
