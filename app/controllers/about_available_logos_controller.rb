class AboutAvailableLogosController < ApplicationController
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
    if is_loa1?
      @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(filter_by_loa(current_identity_providers, 'LEVEL_1'))
      render :certified_companies_LOA1
    else
      @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
      render :certified_companies_LOA2
    end
  end

  def identity_accounts
    if is_loa1?
      render :identity_accounts_LOA1
    else
      render :identity_accounts_LOA2
    end
  end

  def choosing_a_company
    render :choosing_a_company
  end

private

  def filter_by_loa(identity_providers, level_of_assurance)
    identity_providers.select { |idp| idp.levels_of_assurance.min == level_of_assurance }
  end
end
