require 'partials/viewable_idp_partial_controller'

class AboutLoa2VariantController < ApplicationController
  include ViewableIdpPartialController

  def index
    @transaction = current_transaction
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_loa)
    render 'about_variant/about'
  end
end
