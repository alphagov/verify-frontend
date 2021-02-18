class FeedbackLandingController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables
  before_action { @hide_feedback_link = true }

  def index
    flash["feedback_referer"] = request.referer
    flash["feedback_source"] = params["feedback-source"] || flash["feedback_source"]
    @feedback_landing_heading = t("hub.feedback_landing.basic_heading")

    return if current_transaction_simple_id.nil?

    @other_ways_heading = t("hub.feedback_landing.services.heading")
    @other_ways_text = current_transaction.other_ways_text
    @service_name = current_transaction.name
    @feedback_landing_heading = t("hub.feedback_landing.heading", service_name: @service_name)
  end
end
