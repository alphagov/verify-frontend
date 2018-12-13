class RedirectToRpController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def redirect_to_rp
    simple_id = params[:transaction_simple_id]
    begin
      rp_url = REDIRECT_TO_RP_LIST[simple_id]['url']
      ab_test = REDIRECT_TO_RP_LIST[simple_id]['ab_test']
    rescue StandardError
      redirect_to start_path
      return
    end
    FEDERATION_REPORTER.report_external_ab_test(request, ab_test)
    redirect_to rp_url
  end
end
