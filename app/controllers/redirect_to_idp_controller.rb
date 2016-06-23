class RedirectToIdpController < ApplicationController
  def index
    @saml_message = SESSION_PROXY.idp_authn_request(cookies)
    @hints = []
    if IDP_HINTS_CHECKER.enabled?(selected_identity_provider.simple_id) && @saml_message.registration
      @hints = HintsMapper.map_answers_to_hints(selected_answer_store.selected_answers)
    end
  end
end
