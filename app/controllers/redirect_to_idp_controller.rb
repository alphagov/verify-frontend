require "#{Rails.root}/lib/hints_mapper"

class RedirectToIdpController < ApplicationController
  def index
    @saml_message = SESSION_PROXY.idp_authn_request(cookies)
    @hints = HintsMapper.map_answers_to_hints(selected_answer_store.selected_answers)
  end
end
