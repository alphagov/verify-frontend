class FeedbackController < ApplicationController
  skip_before_action :validate_cookies

  def index
    @form = FeedbackForm.new(referer: request.referer, user_agent: request.user_agent)
  end

  def submit
    @form = FeedbackForm.new(params['feedback_form'] || {})
    if @form.valid?
      session_id = cookies[CookieNames::SESSION_ID_COOKIE_NAME]
      if FEEDBACK_SERVICE.submit!(session_id, @form)
        query_params = { "emailProvided" => @form.reply_required?, "sessionValid" => session_id.present? }
        redirect_to feedback_sent_path(query_params)
      else
        flash.now[:errors] = t('hub.feedback.errors.send_failure')
        render :index
      end
    else
      flash.now[:errors] = @form.errors[:base].first
      render :index
    end
  end
end
