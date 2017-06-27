class RedirectToIdpController < ApplicationController
  def index
    saml_message = SESSION_PROXY.idp_authn_request(session[:verify_session_id])
    @request = IdentityProviderRequest.new(
      saml_message,
      selected_identity_provider.simple_id,
      selected_answer_store.selected_answers
    )
  end
end
