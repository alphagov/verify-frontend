class AboutController < ApplicationController
  layout 'start', except: [:choosing_a_company]

  def index
    transaction_analytics_description =
      FEDERATION_TRANSLATOR.translate("rps.#{federation_info[:transaction_simple_id]}.analyticsDescription")

    ANALYTICS_REPORTER.report_custom_variable(
      request,
      "The Yes option was selected on the start page #{transaction_analytics_description}",
      Analytics::CustomVariable.build(:rp, transaction_analytics_description))
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
