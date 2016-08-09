require 'cookies/cookies'
require 'ab_test/ab_test'

module AbTestHelper
  def ab_test(experiment_name, default = nil)
    alternative_name = Cookies.parse_json(cookies[CookieNames::AB_TEST])[experiment_name]
    AbTest.alternative_name_for_experiment(experiment_name, alternative_name, default)
  end
end
