require "partials/viewable_idp_partial_controller"

class AboutController < ApplicationController
  include ViewableIdpPartialController

  layout "slides", only: :about_verify

  def about_verify
    @tailored_text = current_transaction.tailored_text
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_available_identity_providers_for_registration)
    @next_page_path = is_journey_loa1? ? choose_a_certified_company_path : will_it_work_for_me_path
    render :how_verify_works
  end

  def about_choosing_a_company
    @continue_path = is_journey_loa1? ? choose_a_certified_company_path : will_it_work_for_me_path
    render :choosing_a_company
  end

  def about_documents
    selected_documents = {
      has_valid_passport: true,
      has_driving_license: true,
      has_phone_can_app: true,
      has_credit_card: true,
    }

    selected_answer_store.store_selected_answers("documents", selected_documents)
    render :documents
  end

  def prove_your_identity_another_way
    @other_ways_text = current_transaction.other_ways_text
    @service_name = current_transaction.name

    render :prove_your_identity_another_way
  end
end
