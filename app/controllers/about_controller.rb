class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
  end

  def certified_companies
    federation_info = FEDERATION_INFO_GETTER.get_info(cookies)
    @identity_providers = federation_info[:idp_display_data]
    cvar = Analytics::CustomVariable.build(:rp, federation_info[:transaction_entity_id])
    ANALYTICS_REPORTER.report_custom_variable(request, 'The Yes option was selected on the introduction page', cvar)
  end

  def choosing_a_company
  end
end
