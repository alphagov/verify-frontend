class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
    cvar = Analytics::CustomVariable.build(:rp, federation_info[:transaction_entity_id])
    ANALYTICS_REPORTER.report_custom_variable(request, 'The Yes option was selected on the introduction page', cvar)
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
