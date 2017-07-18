class RedirectToIdpQuestionController < ApplicationController
  def index
    @idp = decorated_idp
    @form = InterstitialQuestionForm.new({})
  end

  def continue
    @form = InterstitialQuestionForm.new(params['interstitial_question_form'] || {})
    if @form.valid?
      if @form.is_yes_selected?
        selected_answer_store.store_selected_answers('interstitial', @form.selected_answers)
        redirect_to redirect_to_idp_warning_path
      else
        redirect_to idp_wont_work_for_you_one_doc_path
      end
    else
      @idp = decorated_idp
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render 'index'
    end
  end

  def idp_wont_work_for_you
    @idp = decorated_idp
    render 'idp_wont_work_for_you'
  end

private

  def decorated_idp
    @decorated_idp ||= IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end
end
