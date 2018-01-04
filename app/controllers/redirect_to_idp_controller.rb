require 'partials/idp_selection_partial_controller'

class RedirectToIdpController < ApplicationController
  include IdpSelectionPartialController

  def register
    request_form
    report_idp_registration_to_piwik(recommended)
    render :redirect_to_idp
  end

  def sign_in
    request_form
    FEDERATION_REPORTER.report_sign_in_idp_selection(current_transaction, request, session[:selected_idp_name])
    render :redirect_to_idp
  end

private

  def request_form
    saml_message = SAML_PROXY_API.authn_request(session[:verify_session_id])
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
