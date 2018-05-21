require 'partials/viewable_idp_partial_controller'

class ChooseACertifiedCompanyLoa1VariantController < ApplicationController
  include ViewableIdpPartialController

  def index
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR_VARIANT.decorate_collection(current_identity_providers_for_loa)
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render 'choose_a_certified_company/choose_a_certified_company_LOA1'
  end
end
