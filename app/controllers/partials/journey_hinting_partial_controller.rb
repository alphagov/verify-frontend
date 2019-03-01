# Shared methods for controllers which use the journey hint cookie to give users IDP suggestions
module JourneyHintingPartialController
  PENDING_STATUS = 'PENDING'.freeze

  def journey_hint_value
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT])
  rescue MultiJson::ParseError
    nil
  end

  def with(value)
    unless value.nil?
      yield value
    end
  end

  def attempted_entity_id
    with(journey_hint_value) { |h| h['ATTEMPT'] }
  end

  def success_entity_id
    with(journey_hint_value) { |h| h['SUCCESS'] }
  end

  def resume_link?
    with(journey_hint_value) { |h| h['RESUMELINK'] }
  end

  def resume_link_idp
    with(journey_hint_value) { |h| h.dig('RESUMELINK', 'IDP') }
  end

  def last_status
    with(journey_hint_value) { |h| h['STATE'] }
  end

  def is_last_status?(status)
    with(last_status) { |last_status_value| last_status_value['STATUS'] == status }
  end

  def last_idp
    with(last_status) { |last_status_value| last_status_value['IDP'] }
  end

  def last_rp
    with(last_status) { |last_status_value| last_status_value['RP'] }
  end

  def user_followed_journey_hint(entity_id_followed_by_user)
    with(success_entity_id) { |hinted_id| hinted_id == entity_id_followed_by_user }
  end

  def retrieve_decorated_singleton_idp_array_by_entity_id(providers, entity_id)
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(providers.select { |idp| idp.entity_id == entity_id })
  end

  def retrieve_decorated_singleton_idp_array_by_simple_id(providers, simple_id)
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(providers.select { |idp| idp.simple_id == simple_id })
  end
end
