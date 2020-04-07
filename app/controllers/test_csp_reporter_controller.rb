class TestCspReporterController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_before_action :verify_authenticity_token
  skip_after_action :store_locale_in_cookie

  def report
    # dump request to logs and do nothing else
    logger.info(request.body.read)
    head :ok
  end
end
