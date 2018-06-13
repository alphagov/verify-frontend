require 'partials/viewable_idp_partial_controller'

class ChooseACertifiedCompanyLoa2VariantController < ApplicationController
  include ChooseACertifiedCompanyAbout
  include ViewableIdpPartialController

  def index
    @driving_licence = driving_licence
    @passport = passport
    @smart_phone = smart_phone unless driving_licence || passport
    @non_uk_id_document = non_uk_id_document unless driving_licence || passport
    @any_docs = @driving_licence || @passport || @smart_phone
    @transaction = current_transaction
    session[:selected_answers]&.delete('interstitial')
    suggestions = recommendation_engine.get_suggested_idps(current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:recommended])
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely])
    session[:user_segments] = suggestions[:user_segments]
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render 'choose_a_certified_company/choose_a_certified_company_LOA2_variant'
  end

  def select_idp
    select_viewable_idp_for_loa(params.fetch('entity_id')) do |decorated_idp|
      session[:selected_idp_was_recommended] = recommendation_engine.recommended?(decorated_idp.identity_provider, current_identity_providers_for_loa, selected_evidence, current_transaction_simple_id)
      redirect_to warning_or_question_page(decorated_idp)
    end
  end

private

  def warning_or_question_page(decorated_idp)
    if not_more_than_one_uk_doc_selected && interstitial_question_flag_enabled_for(decorated_idp)
      redirect_to_idp_question_path
    else
      redirect_to_idp_warning_path
    end
  end

  def not_more_than_one_uk_doc_selected
    (%i[passport driving_licence] & selected_evidence).size <= 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question, decorated_idp.simple_id)
  end

  def recommendation_engine
    IDP_RECOMMENDATION_ENGINE
  end

  def driving_licence
    selected_answer_store.selected_evidence_for('documents').include?(:driving_licence) ||
      selected_answer_store.selected_evidence_for('documents').include?(:ni_driving_licence)
  end

  def passport
    selected_answer_store.selected_evidence_for('documents').include?(:passport)
  end

  def smart_phone
    selected_answer_store.selected_evidence_for('other_documents').include?(:smart_phone)
  end

  def non_uk_id_document
    selected_answer_store.selected_evidence_for('other_documents').include?(:non_uk_id_document)
  end
end
