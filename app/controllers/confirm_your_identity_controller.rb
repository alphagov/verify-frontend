class ConfirmYourIdentityController < ApplicationController
  def index
    if !cookies.has_key?(CookieNames::VERIFY_JOURNEY_HINT) || cookies.fetch(CookieNames::VERIFY_JOURNEY_HINT) == ''
      redirect_to sign_in_path
    else
      journey_hint_cookie = cookies.select { |name, _| name.equal?(CookieNames::VERIFY_JOURNEY_HINT) }.to_h
      idp_entity_id = COOKIE_DECRYPTOR.decrypt(journey_hint_cookie.to_h)['entityId']

      federation_info = SESSION_PROXY.federation_info_for_session(cookies)
      identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(federation_info.idps)
      @identity_providers = identity_providers.select { |idp| idp.entity_id == idp_entity_id }
    end

    transaction_details = TRANSACTION_INFO_GETTER.get_info(cookies)
    @transaction_name = transaction_details.name
  end
end
