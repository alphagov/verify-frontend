class AboutController < ApplicationController
  layout 'slides', except: [:choosing_a_company]
  include AbTestHelper

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
    FEDERATION_REPORTER.report_loa_requested(request, session[:requested_loa])
    @tailored_text = current_transaction.tailored_text
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
  end
end
