class SelectRoute
  A_ROUTE = 'control'.freeze
  B_ROUTE = 'variant'.freeze
  MATCHES = true.freeze
  DOES_NOT_MATCH = false.freeze

  def initialize(experiment_name, route)
    @experiment_name = experiment_name
    @experiment_route = "#{@experiment_name}_#{route}"
  end

  def matches?(request)
    does_request_match_experiment?(request) ?
      (
        report_to_piwik(request)
        MATCHES
      )
      : DOES_NOT_MATCH
  end

  private

    def does_request_match_experiment?(request)
      request_experiment_route = extract_experiment_route_from_cookie(request.cookies[CookieNames::AB_TEST])

      @experiment_route == request_experiment_route
    end

    def extract_experiment_route_from_cookie(ab_test_cookie)
      experiment_name = Cookies.parse_json(ab_test_cookie)[@experiment_name]

      AB_TESTS[@experiment_name] ? AB_TESTS[@experiment_name].alternative_name(experiment_name) : 'default'
    end

    def report_to_piwik(request)
      reported_alternative = Cookies.parse_json(request.cookies[CookieNames::AB_TEST])[@experiment_name]
      transaction_id = request.session[:transaction_simple_id]
      AbTest.report(@experiment_name, reported_alternative, transaction_id, request)
   end
end