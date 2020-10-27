require "partials/viewable_idp_partial_controller"
require "partials/variant_partial_controller"

class AboutLoa2Controller < ApplicationController
  include ViewableIdpPartialController
  include VariantPartialController

  layout "slides", except: [:choosing_a_company]

  def index
    @tailored_text = current_transaction.tailored_text
    variant_c_idps = current_identity_providers_for_loa_by_variant("c")
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(variant_c_idps)
    render "about_variant_c/about_combined_LOA2"
  end

  def choosing_a_company
    render "about/choosing_a_company"
  end
end
