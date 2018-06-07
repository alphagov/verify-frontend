require 'partials/viewable_idp_partial_controller'

class AboutLoa2VariantController < ApplicationController
  include ViewableIdpPartialController

  def choosing_a_company
    @transaction = current_transaction
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_loa)
    render 'about_variant/choosing_a_company'
  end
end
