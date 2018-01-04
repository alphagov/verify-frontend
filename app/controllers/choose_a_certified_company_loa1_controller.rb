require 'partials/viewable_idp_partial_controller'

class ChooseACertifiedCompanyLoa1Controller < ApplicationController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  def index
    loa1_idps = current_identity_providers_for_loa
                    .select { |idp| idp.levels_of_assurance.min == 'LEVEL_1' }
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(loa1_idps)
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render 'choose_a_certified_company/choose_a_certified_company_LOA1'
  end

  def select_idp
    selected_answer_store.store_selected_answers('interstitial', {})
    select_viewable_idp_for_loa(params.fetch('entity_id')) do |decorated_idp|
      session[:selected_idp_was_recommended] = true
      redirect_to warning_or_question_page(decorated_idp)
    end
  end

private

  def warning_or_question_page(decorated_idp)
    if interstitial_question_flag_enabled_for(decorated_idp)
      redirect_to_idp_question_path
    else
      redirect_to_idp_warning_path
    end
  end

  def only_one_uk_doc_selected
    (%i[passport driving_licence] & selected_evidence).size == 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question_loa1, decorated_idp.simple_id)
  end
end
