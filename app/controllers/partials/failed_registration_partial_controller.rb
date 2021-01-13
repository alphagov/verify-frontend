require "partials/viewable_idp_partial_controller"
require "partials/user_characteristics_partial_controller"

module FailedRegistrationPartialController
  include ViewableIdpPartialController
  include UserCharacteristicsPartialController

protected

  def choose_view(loa_suffix)
    if continue_on_failed_registration_rp?
      "failed_registration/index_continue_on_failed_registration_#{loa_suffix}"
    else
      add_current_idp_to_idps_tried
      @remaining_options_partial = tried_all_idps? ? "failed_registration/options_with_no_other_idps" : "failed_registration/options_with_other_idps"
      "failed_registration/index_#{loa_suffix}"
    end
  end

private

  def continue_on_failed_registration_rp?
    CONTINUE_ON_FAILED_REGISTRATION_RPS.include?(current_transaction_simple_id)
  end

  def tried_all_idps?
    (possible_idps - idps_tried.to_a).none?
  end

  def suggested_idps
    @suggested_idps ||= @idp_recommendation_engine.get_suggested_idps_for_registration(
      current_available_identity_providers_for_registration,
      selected_evidence,
      current_transaction_simple_id,
      idps_tried,
    )
  end

  def possible_idps
    recommended_idps + unlikely_idps
  end

  def recommended_idps
    suggested_idps[:recommended]
  end

  def unlikely_idps
    suggested_idps[:unlikely]
  end

  def add_current_idp_to_idps_tried
    idps_tried.add selected_identity_provider.simple_id
  end
end
