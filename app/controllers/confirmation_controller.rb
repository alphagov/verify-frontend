class ConfirmationController < ApplicationController
  layout 'slides'

  def index
    selected_idp = session.fetch(:selected_idp)
    @idp_name = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(IdentityProvider.new(selected_idp)).display_name
    @transaction_name = TRANSACTION_INFO_GETTER.get_info(session).name
  end

private

  def retrieve_last_used_idp(idp_entity_id)
    federation_info = SESSION_PROXY.federation_info_for_session(cookies)
    var = federation_info.idps.select { |idp| idp.entity_id == idp_entity_id }
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(var)
  end
end
