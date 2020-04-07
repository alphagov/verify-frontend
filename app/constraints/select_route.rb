require "cookies/cookies"
require "ab_test/ab_test"

class SelectRoute
  def initialize(experiment_name, route, config = { experiment_loa: nil,
                                                    trial_enabled: false })
    @experiment_name = experiment_name
    @experiment_route = "#{@experiment_name}_#{route}"
    @experiment_loa = config[:experiment_loa]
    @trial_enabled = config[:trial_enabled]
  end

  def matches?(request)
    if cookie_matches_experiment?(request)
      AbTest.report_ab_test_details(request, @experiment_name) if loa_matches_experiment?(request)
      true
    else
      false
    end
  end

private

  def cookie_matches_experiment?(request)
    request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])
    if @trial_enabled && request.cookies[CookieNames::AB_TEST_TRIAL] == @experiment_name
      true
    else
      @experiment_route == request_experiment_route
    end
  end

  def loa_matches_experiment?(request)
    @experiment_loa.nil? || request.session[:requested_loa] == @experiment_loa
  end

  def extract_experiment_route_from_cookie(ab_test_cookie)
    experiment_name = Cookies.parse_json(ab_test_cookie)[@experiment_name]

    AB_TESTS[@experiment_name] ? AB_TESTS[@experiment_name].alternative_name(experiment_name) : "default"
  end
end
