module IdpSelectionPartialController
  def ajax_idp_redirection_sign_in_request
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])

    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initilization(outbound_saml_message)
    render json: idp_request
  end

  def ajax_idp_redirection_registration_request(recommended)
    report_idp_registration_to_piwik(recommended)
    outbound_saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
    idp_request = idp_request_initilization(outbound_saml_message)
    render json: idp_request.to_json(methods: :hints)
  end

  def report_idp_registration_to_piwik(recommended)
    FEDERATION_REPORTER.report_idp_registration(
      current_transaction: current_transaction,
      request: request,
      idp_name: session[:selected_idp_name],
      idp_name_history: session[:selected_idp_names],
      evidence: selected_answer_store.selected_evidence,
      recommended: recommended,
      user_segments: session[:user_segments]
    )
  end

  def idp_request_initilization(outbound_saml_message)
    IdentityProviderRequest.new(
      outbound_saml_message,
      selected_identity_provider.simple_id,
      selected_answer_store.selected_answers
    )
  end
end
