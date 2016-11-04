class FeedbackController < ApplicationController
  skip_before_action :validate_session

  def index
    @form = FeedbackForm.new({})
    flash['feedback_referer'] = request.referer
  end

  def submit
    @form = FeedbackForm.new(feedback_form_params)
    flash.keep('feedback_referer')
    if @form.valid?
      session_id = session[:verify_session_id]
      if FEEDBACK_SERVICE.submit!(session_id, @form)
        flash['email_provided'] = @form.reply_required?
        redirect_to feedback_sent_path
      else
        @has_email_sending_error = true
        render :index
      end
    else
      flash.now[:errors] = @form.errors[:base].first
      render :index
    end
  end

private

  def feedback_form_params
    (params['feedback_form'] || {}).merge(user_agent: request.user_agent, referer: flash['feedback_referer'])
  end
end
