require 'cookies/cookies'

class SelectRoute
  def initialize(experiment_name, route, is_start_of_test = false, experiment_loa = nil)
    @experiment_name = experiment_name
    @experiment_route = "#{@experiment_name}_#{route}"
    @experiment_loa = experiment_loa
    @is_start_of_test = is_start_of_test
  end

  def matches?(request)
    if cookie_matches_experiment?(request)
      AbTest.report_ab_test_details(request, @experiment_name) if @is_start_of_test && loa_matches_experiment?(request)
      true
    else
      false
    end
  end

private

  def cookie_matches_experiment?(request)
    request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])

    @experiment_route == request_experiment_route
  end

  def loa_matches_experiment?(request)
    @experiment_loa.nil? || request.session[:requested_loa] == @experiment_loa
  end

  def extract_experiment_route_from_cookie(ab_test_cookie)
    experiment_name = Cookies.parse_json(ab_test_cookie)[@experiment_name]

    AB_TESTS[@experiment_name] ? AB_TESTS[@experiment_name].alternative_name(experiment_name) : 'default'
  end
end
