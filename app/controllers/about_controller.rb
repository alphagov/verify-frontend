require "partials/viewable_idp_partial_controller"

class AboutController < ApplicationController
  include ViewableIdpPartialController

  layout "slides", only: :about_verify

  def about_verify
    @tailored_text = current_transaction.tailored_text
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers_available_for_registration)
    @next_page_path = is_journey_loa1? ? choose_a_certified_company_path : will_it_work_for_me_path
    if SIGN_UPS_ENABLED
      render :how_verify_works
    else
      redirect_to("/start")
    end
  end

  def about_choosing_a_company
    @continue_path = is_journey_loa1? ? choose_a_certified_company_path : will_it_work_for_me_path
    if SIGN_UPS_ENABLED
      render :choosing_a_company
    else
      redirect_to("/start")
    end
  end

  def about_documents
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(identity_providers_available_for_registration)
    if SIGN_UPS_ENABLED
      render :documents
    else
      redirect_to("/start")
    end
  end

  def prove_your_identity_another_way
    @other_ways_text = current_transaction.other_ways_text
    @service_name = current_transaction.name
    if SIGN_UPS_ENABLED
      render :prove_your_identity_another_way
    else
      redirect_to("/start")
    end
  end
end
