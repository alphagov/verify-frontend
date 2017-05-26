class SelectRoute
  def initialize(experimentName, route)
    @experimentName = experimentName
    @route = route
  end

  def matches?(request)
    # reportToPiwik(request)
    is_in_a_group?(request)
  end

  private

    def reportToPiwik(request)
      reported_alternative = Cookies.parse_json(request.cookies[CookieNames::AB_TEST])[@experimentName]
      transaction_id = request.session[:transaction_simple_id]
      AbTest.report(@experimentName, reported_alternative, transaction_id, request)
    end

    def is_in_a_group?(request)
      experimentRoute = @experimentName + '_' + @route
      alternative_name = alternative_name_split_questions(request)

      experimentRoute == alternative_name
    end

    def alternative_name_split_questions(request)
      ab_test_cookie = Cookies.parse_json(request.cookies[CookieNames::AB_TEST])[@experimentName]

      if AB_TESTS[@experimentName]
        AB_TESTS[@experimentName].alternative_name(ab_test_cookie)
      else
        'default'
      end
    end
end