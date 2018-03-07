require 'partials/viewable_idp_partial_controller'

class ChooseACertifiedCompanyLoa2VariantController < ApplicationController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_loa)

    render 'choose_a_certified_company/choose_a_certified_company_LOA2_variant'
  end

  def select_idp
    select_viewable_idp_for_loa(params.fetch('entity_id')) do
      redirect_to warning_page
    end
  end

private

  def warning_page
    redirect_to_idp_warning_path
  end
end
