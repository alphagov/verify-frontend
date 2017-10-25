class RedirectToIdpController < ApplicationController
  def index
    Rails.logger.error(request)
    FEDERATION_REPORTER.report_idp_registration(current_transaction, request, idp_name, selected_idp_names, selected_answer_store.selected_evidence, recommended)
    
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, idp_name)
    
    saml_message = SESSION_PROXY.idp_authn_request(session[:verify_session_id])
    @request = IdentityProviderRequest.new(
      saml_message,
      selected_identity_provider.simple_id,
      selected_answer_store.selected_answers
    )
  end
end
