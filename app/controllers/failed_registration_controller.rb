class FailedRegistrationController < ApplicationController
  def index
    @idp = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(selected_identity_provider)
  end

  def try_another_idp
    SESSION_PROXY.restart_session(cookies)
    redirect_to select_documents_path
  end
end
