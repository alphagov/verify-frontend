class RedirectToIdpController < ApplicationController
  def register
    request_form
    FEDERATION_REPORTER.report_idp_registration(current_transaction, request, session[:selected_idp_name], session[:selected_idp_names], selected_answer_store.selected_evidence, recommended)
    render :redirect_to_idp
  end

  def sign_in
    request_form
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])
    render :redirect_to_idp
  end

private

  def request_form
    saml_message = SESSION_PROXY.idp_authn_request(session[:verify_session_id])
    @request = idp_request_initilization(saml_message)
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
