require 'cookies/cookies'

module AbTestHelper
  def ab_test(experiment_name)
    cookie_value = Cookies.parse_json(cookies[CookieNames::AB_TEST])[experiment_name]
    ::AB_TESTS[experiment_name].alternative_name(
      cookie_value
    )
  end
end
