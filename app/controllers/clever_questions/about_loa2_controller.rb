class CleverQuestions::AboutLoa2Controller < ApplicationController
  def certified_companies
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_loa)
    render 'clever_questions/about/certified_companies_LOA2'
  end

  def choosing_a_company
    render 'clever_questions/about/choosing_a_company'
  end
end
