class CleverQuestions::AboutLoa2Controller < ApplicationController
  def identity_providers
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers)
    render 'clever_questions/about/identity_providers_LOA2'
  end

  def choosing_an_identity_provider
    render 'clever_questions/about/choosing_an_identity_provider'
  end
end
