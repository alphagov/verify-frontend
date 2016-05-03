class ConfirmYourIdentityController < ApplicationController
  def index
    idp_entity_id = cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]

    if idp_entity_id.nil?
      redirect_to sign_in_path
    end

    federation_info = SESSION_PROXY.federation_info_for_session(cookies)
    identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(federation_info.idps)
    @identity_providers = identity_providers.select { |idp| idp.entity_id == idp_entity_id }

    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @transaction_name = transaction_details.name
  end
end
