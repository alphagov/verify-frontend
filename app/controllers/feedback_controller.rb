class FeedbackController < ApplicationController
  def index
    @form = FeedbackForm.new({})
  end

  def submit
    @form = FeedbackForm.new(params['feedback_form'] || {})
    if @form.valid?
      redirect_to feedback_sent_path
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :index
    end
  end
end
