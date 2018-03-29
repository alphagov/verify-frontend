require 'ab_test/ab_test'

class StartController < ApplicationController
  layout 'slides'
  before_action :set_device_type_evidence

  AB_EXPERIMENT_NAME = 'short_questions_v2'.freeze

  def index
    @form = StartForm.new({})

    FEDERATION_REPORTER.report_start_page(current_transaction, request) unless session[:requested_loa] == 'LEVEL_2' # ab test variant hack, remove 'unless' with teardown of HUB-72

    render :start
  end

  def request_post
    @form = StartForm.new(params['start_form'] || {})
    if @form.valid?
      if @form.registration?
        register
      else
        FEDERATION_REPORTER.report_sign_in(current_transaction, request)
        redirect_to sign_in_path
      end
    else
      flash.now[:errors] = @form.errors.full_messages.join(', ')
      render :start
    end
  end

  def register
    FEDERATION_REPORTER.report_registration(current_transaction, request)
    redirect_to about_path
  end

  # TODO HUB-83 Remove this method when tearing down the AB Test variant.
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

  # TODO HUB-83 Remove these two methods when tearing down the AB Test variant.
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
