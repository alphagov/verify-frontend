class FeedbackLandingController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  before_action { @hide_feedback_link = true }

  def index
    flash['feedback_source'] = params['feedback-source'].nil? ? flash['feedback_source'] : params['feedback-source']
    flash['feedback_referer'] = request.referer
    @other_ways_heading = t('hub.feedback_landing.services.heading')
    @other_ways_text = current_transaction.other_ways_text
    @service_name = current_transaction.name
  end
end
