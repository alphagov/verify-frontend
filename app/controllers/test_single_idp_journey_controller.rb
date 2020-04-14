class TestSingleIdpJourneyController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  skip_after_action :store_locale_in_cookie
  layout "test"

  def index
    render "index"
  end
end
