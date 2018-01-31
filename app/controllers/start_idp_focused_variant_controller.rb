require 'ab_test/ab_test'
require 'partials/viewable_idp_partial_controller'
require 'partials/idp_selection_partial_controller'
require 'partials/analytics_partial_controller'

class StartIdpFocusedVariantController < ApplicationController
  layout 'single_idp_focused_variant'
  before_action :set_device_type_evidence
  include ViewableIdpPartialController
  include IdpSelectionPartialController
  include AnalyticsPartialController

  AB_EXPERIMENT_NAME = 'idp_focused_v2'.freeze


  def index
    @identity_providers = IDENTITY_PROVIDER_DISPLAY_DECORATOR.decorate_collection(current_identity_providers_for_sign_in)
    @other_ways_description = current_transaction.other_ways_description
    render :start
  end

  def select_idp
    select_viewable_idp_for_sign_in(params.fetch('entity_id')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      redirect_to redirect_to_idp_sign_in_path
    end
  end

  def select_idp_ajax
    select_viewable_idp_for_sign_in(params.fetch('entityId')) do |decorated_idp|
      sign_in(decorated_idp.entity_id, decorated_idp.display_name)
      ajax_idp_redirection_sign_in_request
    end
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to about_path
  end

  # TODO HUB-2 Remove this method when tearing down the AB Test variant.
  def set_piwik_custom_variables
    super

    if cookie_matches_experiment?(request)
      if AbTest::experiment_is_valid(current_transaction_simple_id, AB_EXPERIMENT_NAME)
        ab_test_alternative_name = AbTest::get_alternative_name(request, AB_EXPERIMENT_NAME)
        @piwik_custom_variables.push(
          Analytics::CustomVariable.build_for_js_client(:ab_test, ab_test_alternative_name)
        )
      end
    end
  end

private

  # TODO HUB-2 Remove these two methods when tearing down the AB Test variant.
  def cookie_matches_experiment?(request)
    request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])
    request_experiment_route.include?(AB_EXPERIMENT_NAME)
  end

  def extract_experiment_route_from_cookie(ab_test_cookie)
    alternative_name = Cookies.parse_json(ab_test_cookie)[AB_EXPERIMENT_NAME]
    AB_TESTS[AB_EXPERIMENT_NAME] ? AB_TESTS[AB_EXPERIMENT_NAME].alternative_name(alternative_name) : 'default'
  end

  def sign_in(entity_id, idp_name)
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    POLICY_PROXY.select_idp(session[:verify_session_id], entity_id, session['requested_loa'])
    set_journey_hint(entity_id)
    session[:selected_idp_name] = idp_name
  end
end
