class RedirectToIdpController < ApplicationController
  def register
    FEDERATION_REPORTER.report_idp_registration(request, session[:selected_idp_name], session[:selected_idp_names], selected_answer_store.selected_evidence, recommended)
    request_form
    render :redirect_to_idp
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in_idp_selection(request, session[:selected_idp_name])
    request_form
    render :redirect_to_idp
  end

private

  def request_form
    saml_message = SESSION_PROXY.idp_authn_request(session[:verify_session_id])
    @request = IdentityProviderRequest.new(
      saml_message,
      selected_identity_provider.simple_id,
      selected_answer_store.selected_answers
    )
  end

  def recommended
    begin
      if session.fetch(:selected_idp_was_recommended)
        '(recommended)'
      else
        '(not recommended)'
      end
    rescue KeyError
      '(idp recommendation key not set)'
    end
  end
end
