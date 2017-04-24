class AboutController < ConfigurableJourneyController
  layout 'slides', except: [:choosing_a_company]
  include AbTestHelper

  def index
    FEDERATION_REPORTER.report_registration(
      current_transaction,
      request
    )
    FEDERATION_REPORTER.report_loa_requested(request, session[:requested_loa])
    @tailored_text = current_transaction.tailored_text
    render :about
  end

  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
    if is_loa1?
      render :certified_companies_LOA1
    else
      render :certified_companies_LOA2
    end
  end

  def identify_accounts
    render :identity_accounts
  end

  def choosing_a_company
    render :choosing_a_company
  end
end
