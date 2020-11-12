require "partials/viewable_idp_partial_controller"

class AboutLoa2Controller < ApplicationController
  include ViewableIdpPartialController

  layout "slides", except: [:choosing_a_company]

  def index
    @tailored_text = current_transaction.tailored_text
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_available_identity_providers_for_registration_loa2(current_transaction_entity_id))
    render "about/about_combined_LOA2"
  end

  def choosing_a_company
    render "about/choosing_a_company"
  end
end
