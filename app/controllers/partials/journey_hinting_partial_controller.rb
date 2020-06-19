require "partials/viewable_idp_partial_controller"

# Shared methods for controllers which use the journey hint cookie to give users IDP suggestions
module JourneyHintingPartialController
  include ViewableIdpPartialController
  PENDING_STATUS = "PENDING".freeze
  FAILED_STATUS = "FAILED".freeze

  def attempted_entity_id
    journey_hint_value.nil? ? nil : journey_hint_value["ATTEMPT"]
  end

  def success_entity_id
    journey_hint_value.nil? ? nil : journey_hint_value["SUCCESS"]
  end

  def resume_link?
    journey_hint = journey_hint_value
    !(journey_hint.nil? || journey_hint.fetch("RESUMELINK", nil).nil?)
  end

  def resume_link_idp
    journey_hint = journey_hint_value
    journey_hint.nil? ? nil : journey_hint.dig("RESUMELINK", "IDP")
  end

  def last_status
    journey_hint = journey_hint_value
    journey_hint.nil? ? nil : journey_hint["STATE"]
  end

  def is_last_status?(status)
    last_status_value = last_status
    !last_status_value.nil? && last_status_value["STATUS"] == status
  end

  def last_idp
    last_status_value = last_status
    last_status_value.nil? ? nil : last_status_value.fetch("IDP", nil)
  end

  def last_rp
    last_status_value = last_status
    last_status_value.nil? ? nil : last_status_value.fetch("RP", nil)
  end

  def user_followed_journey_hint(entity_id_followed_by_user)
    hinted_id = success_entity_id
    !hinted_id.nil? && hinted_id == entity_id_followed_by_user
  end

  def decorate_idp_by_entity_id(providers, entity_id)
    retrieved_idp = providers.select { |idp| idp.entity_id == entity_id }.first
    retrieved_idp && IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(retrieved_idp)
  end

  def decorate_idp_by_simple_id(providers, simple_id)
    retrieved_idp = providers.select { |idp| idp.simple_id == simple_id }.first
    retrieved_idp && IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate(retrieved_idp)
  end

  def try_render_journey_hint
    journey_hint_entity_id = success_entity_id
    unless journey_hint_entity_id.nil?
      session[:journey_type] = JourneyType::Verify::SIGN_IN_LAST_SUCCESSFUL_IDP
      @identity_provider = decorate_idp_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id)
      return render "shared/sign_in_hint", layout: "main_layout" unless @identity_provider.nil?
    end

    false
  end

  def remove_hint_and_report
    journey_hint_entity_id = success_entity_id
    idp = journey_hint_entity_id && decorate_idp_by_entity_id(current_available_identity_providers_for_sign_in, journey_hint_entity_id)
    unless idp.nil?
      FEDERATION_REPORTER.report_sign_in_journey_ignored(current_transaction, request, idp.display_name, session[:transaction_simple_id])
    end

    remove_success_journey_hint
  end
end
