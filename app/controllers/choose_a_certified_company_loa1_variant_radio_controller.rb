class ChooseACertifiedCompanyLoa1VariantRadioController < ApplicationController
  include ChooseACertifiedCompanyAbout
  SELECTED_IDP_HISTORY_LENGTH = 5

  def index
    load_loa1_idps
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render 'choose_a_certified_company_variant_radio/choose_a_certified_company_LOA1'
  end

  def select_idp
    if !params['entity_id'].blank?
      selected_answer_store.store_selected_answers('interstitial', {})
      select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
        if decorated_idp.viewable?
          select_registration(decorated_idp)
          session[:selected_idp_was_recommended] = true
          redirect_to idp_or_question_page(decorated_idp)
        else
          something_went_wrong("Couldn't display IDP with entity id: #{decorated_idp.entity_id}")
        end
      end
    else
      flash.now[:errors] = t('hub.choose_a_certified_company.ab_test_radio_variant_validation_error')
      load_loa1_idps
      render 'choose_a_certified_company_variant_radio/choose_a_certified_company_LOA1'
    end
  end

  def select_idp_ajax
    select_viewable_idp(params.fetch('entity_id')) do |decorated_idp|
      if decorated_idp.viewable?
        select_registration(decorated_idp)
        session[:selected_idp_was_recommended] = true
        ajax_idp_redirection_registration_request(recommended)
      else
        render status: :bad_request
      end
    end
  end

private

  def load_loa1_idps
    loa1_idps = current_identity_providers
                                .select { |idp| idp.levels_of_assurance.min == 'LEVEL_1' }
                                .select { |idp| !is_onboarding?(idp) || is_test_rp? }
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(loa1_idps)
  end

  def idp_or_question_page(decorated_idp)
    if interstitial_question_flag_enabled_for(decorated_idp)
      redirect_to_idp_question_path
    else
      redirect_to_idp_register_path
    end
  end

  def only_one_uk_doc_selected
    (%i[passport driving_licence] & selected_evidence).size == 1
  end

  def interstitial_question_flag_enabled_for(decorated_idp)
    IDP_FEATURE_FLAGS_CHECKER.enabled?(:show_interstitial_question_loa1, decorated_idp.simple_id)
  end

  def is_onboarding?(idp)
    LOA1_ONBOARDING_IDPS.include?(idp.simple_id)
  end

  def is_test_rp?
    current_transaction.simple_id == 'test-rp'
  end

  def select_registration(idp)
    POLICY_PROXY.select_idp(session['verify_session_id'], idp.entity_id, true)
    set_journey_hint(idp.entity_id)
    register_idp_selections(idp.display_name)
  end

  def register_idp_selections(idp_name)
    session[:selected_idp_name] = idp_name
    selected_idp_names = session[:selected_idp_names] || []
    if selected_idp_names.size < SELECTED_IDP_HISTORY_LENGTH
      selected_idp_names << idp_name
      session[:selected_idp_names] = selected_idp_names
    end
  end

  def recommended
    begin
      if session.fetch(:selected_idp_was_recommended)
        '(recommended)'
      else
        '(not recommended)'
      end
    rescue KeyError
      '(idp recommendation key not set)'
    end
  end

  def decorated_idp
    %w(headless-rp loa1-test-rp test-rp test-rp-with-continue-on-fail).include? current_transaction.simple_id
  end
end
