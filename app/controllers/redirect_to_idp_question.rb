module RedirectToIdpQuestion
  def idp_wont_work_for_you
    @idp = decorated_idp
    render "redirect_to_idp_question/idp_wont_work_for_you"
  end

  def continue
    @form = InterstitialQuestionForm.new(params["interstitial_question_form"] || {})
    if @form.valid?
      if @form.is_yes_selected?
        selected_answer_store.store_selected_answers("interstitial", @form.selected_answers)
        redirect_to interstitial_selected_path
      else
        redirect_to interstitial_not_selected_path
      end
    else
      @idp = decorated_idp
      flash.now[:errors] = @form.errors.full_messages.join(", ")
      render invalid_interstitial_path
    end
  end

private

  def decorated_idp
    @decorated_idp ||= IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end
end
