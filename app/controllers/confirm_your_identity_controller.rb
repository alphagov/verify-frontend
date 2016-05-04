class ConfirmYourIdentityController < ApplicationController
  def index
    idp_entity_id = cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT]

    @identity_providers = idp_entity_id.nil? ? [] : retrieve_last_used_idp(idp_entity_id)

    if @identity_providers.empty?
      Rails.logger.warn("invalid verify-front-journey-hint entity-id #{idp_entity_id}")
      cookies.delete(CookieNames::VERIFY_FRONT_JOURNEY_HINT)
      redirect_to sign_in_path
    end

    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @transaction_name = transaction_details.name
  end

private

  def retrieve_last_used_idp(idp_entity_id)
    federation_info = SESSION_PROXY.federation_info_for_session(cookies)
    var = federation_info.idps.select { |idp| idp.entity_id == idp_entity_id }
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(var)
  end
end
