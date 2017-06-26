class SelectRoute
  MATCHES = true
  DOES_NOT_MATCH = false

  private_constant :MATCHES
  private_constant :DOES_NOT_MATCH

  def initialize(experiment_name, route, ab_reporter = -> (exp_name, reported_alternative, transaction_id, request) {})
    @experiment_name = experiment_name
    @experiment_route = "#{@experiment_name}_#{route}"
    @ab_reporter = ab_reporter
  end

  def matches?(request)
    if request_matches_experiment?(request)
      report_ab_test_details(request)
      MATCHES
    else
      DOES_NOT_MATCH
    end
  end

private


  def request_matches_experiment?(request)
    request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])

    @experiment_route == request_experiment_route
  end

  def extract_experiment_route_from_cookie(ab_test_cookie)
    experiment_name = Cookies.parse_json(ab_test_cookie)[@experiment_name]

    AB_TESTS[@experiment_name] ? AB_TESTS[@experiment_name].alternative_name(experiment_name) : 'default'
  end

  def report_ab_test_details(request)
    reported_alternative = Cookies.parse_json(request.cookies[CookieNames::AB_TEST])[@experiment_name]
    transaction_id = request.session[:transaction_simple_id]
    @ab_reporter.call(@experiment_name, reported_alternative, transaction_id, request)
  end
end
