class RedirectToIdpQuestionLoa2Controller < ApplicationController
  include RedirectToIdpQuestion

  def index
    @idp = decorated_idp
    @form = InterstitialQuestionForm.new({})
    render 'redirect_to_idp_question/redirect_to_idp_question_LOA2'
  end

  def interstitial_selected_path
    redirect_to_idp_warning_path
  end

  def interstitial_not_selected_path
    idp_wont_work_for_you_one_doc_path
  end

  def invalid_interstial_path
    'redirect_to_idp_question/redirect_to_idp_question_LOA2'
  end
end
