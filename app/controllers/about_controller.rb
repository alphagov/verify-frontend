class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
    FEDERATION_REPORTER.report_registration(federation_info[:transaction_simple_id], request)
  end

  def certified_companies
    @identity_providers = federation_info[:idp_display_data]
  end

  def choosing_a_company
  end

private

  def federation_info
    FEDERATION_INFO_GETTER.get_info(cookies)
  end
end
