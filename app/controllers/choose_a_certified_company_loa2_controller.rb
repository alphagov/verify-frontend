require "partials/journey_hinting_partial_controller"
require "partials/viewable_idp_partial_controller"

class ChooseACertifiedCompanyLoa2Controller < ApplicationController
  include ChooseACertifiedCompanyAbout
  include JourneyHintingPartialController
  include ViewableIdpPartialController
  skip_before_action :render_cross_gov_ga, only: %i{about}

  def index
    session[:selected_answers]&.delete("interstitial")
    suggestions = recommendation_engine.get_suggested_idps_for_registration(current_available_identity_providers_for_registration, selected_evidence, current_transaction_simple_id)
    if THROTTLING_ENABLED && !is_last_status?(FAILED_STATUS)
      throttled_idp_name = users_idp(suggestions)
      throttled_idp_name = throttled_idp_name.split("idps_")[1]
      throttled_idp = suggestions[:recommended].select { |idp| idp.simple_id == throttled_idp_name }
      if throttled_idp.length == 1
        recommended_idps(recommended: throttled_idp)
      else
        recommended_idps(suggestions)
      end
    else
      recommended_idps(suggestions)
    end
    @non_recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(suggestions[:unlikely])
    @non_recommended_idps = order_with_unavailable_last(@non_recommended_idps)
    session[:user_segments] = suggestions[:user_segments]
    FEDERATION_REPORTER.report_number_of_idps_recommended(current_transaction, request, @recommended_idps.length)
    render "choose_a_certified_company/choose_a_certified_company_LOA2"
  end

  def select_idp
    if params[:entity_id].present?
      select_viewable_idp_for_registration(params.fetch("entity_id")) do |decorated_idp|
        session[:selected_idp_was_recommended] = recommendation_engine.recommended?(decorated_idp.identity_provider, current_available_identity_providers_for_registration, selected_evidence, current_transaction_simple_id)
        redirect_to warning_or_question_page(decorated_idp)
      end
    else
      render "errors/something_went_wrong", status: 400
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

  def recommended_idps(list)
    @recommended_idps = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(list[:recommended])
    @recommended_idps = order_with_unavailable_last(@recommended_idps)
  end

  def users_idp(suggested_list)
    cookie = cookies.encrypted[CookieNames::THROTTLING]
    list = suggested_list[:recommended].map { |idp| "idps_#{idp.simple_id}" }

    if list.include?(cookie)
      cookie
    else
      set_throttling_cookie
    end
  end

  def set_throttling_cookie
    idp_name = THROTTLING.get_ab_test_name(rand)
    cookies.encrypted[CookieNames::THROTTLING] = { value: idp_name, expires: 21.days.from_now }
    idp_name
  end
end
