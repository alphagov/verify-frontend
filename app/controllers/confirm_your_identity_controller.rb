class ConfirmYourIdentityController < ApplicationController
  def index
    journey_hint = journey_hint_value

    if journey_hint.nil?
      cookie_error('missing verify-front-journey-hint')
    else
      entity_id = journey_hint['entity_id']

      @transaction_name = TRANSACTION_INFO_GETTER.get_info(cookies).name
      @identity_providers = entity_id.nil? ? [] : retrieve_last_used_idp(entity_id)

      if @identity_providers.empty?
        cookie_error("invalid verify-front-journey-hint entity-id #{entity_id}")
      end
    end
  end

private

  def cookie_error(string)
    Rails.logger.warn(string)
    cookies.delete(CookieNames::VERIFY_FRONT_JOURNEY_HINT)
    redirect_to sign_in_path
  end

  def retrieve_last_used_idp(idp_entity_id)
    federation_info = SESSION_PROXY.federation_info_for_session(cookies)
    var = federation_info.idps.select { |idp| idp.entity_id == idp_entity_id }
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(var)
  end
end
