require 'ab_test/ab_test'

class StartVariantController < ApplicationController
  layout 'slides'

  # TODO TT-1615: Remove after tearing down AB Test.
  AB_EXPERIMENT_NAME = 'loa1_shortened_journey_v3'.freeze

  def index
    @tailored_text = current_transaction.tailored_text
    render :start
  end

  def sign_in
    FEDERATION_REPORTER.report_sign_in(current_transaction, request)
    redirect_to sign_in_path
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to choose_a_certified_company_path
  end

  # TODO TT-1615 Remove this method when tearing down the AB Test variant.
  def set_piwik_custom_variables
    super

    if cookie_matches_experiment?(request) && session[:requested_loa] == 'LEVEL_1'
      if AbTest::experiment_is_valid(current_transaction_simple_id, AB_EXPERIMENT_NAME)
        ab_test_alternative_name = AbTest::get_alternative_name(request, AB_EXPERIMENT_NAME)
        @piwik_custom_variables.push(
          Analytics::CustomVariable.build_for_js_client(:ab_test, ab_test_alternative_name)
        )
      end
    end
  end

private

  # TODO TT-1615 Remove this method when tearing down the AB Test variant.
  def cookie_matches_experiment?(request)
    request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])
    request_experiment_route.include?(AB_EXPERIMENT_NAME)
  end

  def extract_experiment_route_from_cookie(ab_test_cookie)
    alternative_name = Cookies.parse_json(ab_test_cookie)[AB_EXPERIMENT_NAME]
    AB_TESTS[AB_EXPERIMENT_NAME] ? AB_TESTS[AB_EXPERIMENT_NAME].alternative_name(alternative_name) : 'default'
  end
end
