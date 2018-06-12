# Shared methods for controllers which use the journey hint cookie to give users IDP suggestions
module JourneyHintingPartialController
  def journey_hint_value
    MultiJson.load(cookies.encrypted[CookieNames::VERIFY_FRONT_JOURNEY_HINT] ||= '')
  rescue MultiJson::ParseError
    nil
  end

  def entity_id_of_journey_hint
    journey_hint = journey_hint_value
    journey_hint.nil? ? nil : journey_hint['entity_id']
  end

  def entity_id_of_journey_hint_for(status)
    journey_hint = journey_hint_value
    journey_hint.nil? ? nil : journey_hint[status]
  end

  def user_followed_journey_hint(entity_id_followed_by_user)
    hinted_id = find_journey_hint_entity_id
    !hinted_id.nil? && hinted_id == entity_id_followed_by_user
  end

  def find_journey_hint_entity_id
    if journey_hint_status_set?
      entity_id_of_journey_hint_for('SUCCESS')
    else
      entity_id_of_journey_hint
    end
  end

  def retrieve_decorated_singleton_idp_array_by_entity_id(providers, entity_id)
    IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(providers.select { |idp| idp.entity_id == entity_id })
  end

private

  def journey_hint_status_set?
    journey_hint = journey_hint_value
    journey_hint.nil? ? false : journey_hint.keys.count > 1
  end
end
