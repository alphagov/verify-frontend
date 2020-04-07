class FeedbackController < ApplicationController
  skip_before_action :validate_session
  skip_before_action :set_piwik_custom_variables

  def index
    if FEEDBACK_DISABLED
      render :disabled
    else
      render_feedback_form
    end
  end

  def submit
    @form = FeedbackForm.new(feedback_form_params)
    flash.keep("feedback_referer")
    flash.keep("feedback_source")
    if @form.valid?
      session_id = session[:verify_session_id]
      if FEEDBACK_SERVICE.submit!(session_id, @form)
        flash["email_provided"] = @form.reply_required?
        redirect_to feedback_sent_path
      else
        @has_email_sending_error = true
        render :index
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(", ")
      render :index
    end
  end

private

  def feedback_form_params
    (params["feedback_form"] || {}).merge(user_agent: request.user_agent, referer: flash["feedback_referer"])
  end

  def render_feedback_form
    @form = FeedbackForm.new({})
    flash.keep("feedback_referer")
    feedback_source = params["feedback-source"].nil? ? flash["feedback_source"] : params["feedback-source"]
    if feedback_source.nil?
      render
    elsif FEEDBACK_SOURCE_MAPPER.is_feedback_source_valid(feedback_source)
      flash["feedback_source"] = feedback_source
    else
      render "errors/404", status: 400
    end
  end
end
