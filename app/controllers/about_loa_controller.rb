require "partials/viewable_idp_partial_controller"

class AboutLoaController < ApplicationController
  include ViewableIdpPartialController

  helper_method :next_page_path
  layout "slides", except: [:choosing_a_company]

  def index
    @tailored_text = current_transaction.tailored_text
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_available_identity_providers_for_registration)
    render "about/about_combined_LOA"
  end

  def choosing_a_company
    render "about/choosing_a_company"
  end

private

  def next_page_path
    return will_it_work_for_me_path unless request.session[:requested_loa] == "LEVEL_1"

    choose_a_certified_company_path
  end
end
