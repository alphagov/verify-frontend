class FailedSignInController < ApplicationController
  def idp
    @entity = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end
end
