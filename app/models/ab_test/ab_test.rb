require 'analytics/custom_variable'
require 'cookies/cookies'

module AbTest
  def self.alternative_name_for_experiment(experiment_name, alternative_name, default = nil)
    ab_test = ::AB_TESTS[experiment_name]
    ab_test ? ab_test.alternative_name(alternative_name) : default
  end

  def self.report(experiment_name, reported_alternative, transaction_id, request)
    ab_test = ::AB_TESTS[experiment_name]
    if ab_test && !current_transaction_is_excluded_from_ab_test(transaction_id) && !ab_test.concluded?
      alternative_name = AbTest.alternative_name_for_experiment(experiment_name, reported_alternative)
      if reported_alternative_matches_an_allowed_alternative(alternative_name, reported_alternative)
        FEDERATION_REPORTER.report_ab_test(transaction_id, request, alternative_name)
      end
    end
  end

  def self.reported_alternative_matches_an_allowed_alternative(alternative_name, reported_alternative)
    alternative_name && alternative_name == reported_alternative
  end

  def self.set_or_update_ab_test_cookie(current_transaction_simple_id, cookies)
    unless current_transaction_is_excluded_from_ab_test(current_transaction_simple_id)
      ab_test_cookie = cookies[CookieNames::AB_TEST]
      if ab_test_cookie.nil?
        set_ab_test_cookie(experiment_selections, cookies)
      end
      experiment_selection_hash = Cookies.parse_json(ab_test_cookie)
      if is_missing_experiments?(experiment_selection_hash)
        update_ab_test_cookie(experiment_selection_hash, cookies)
      end
    end
  end

  def self.current_transaction_is_excluded_from_ab_test(current_transaction_simple_id)
    RP_CONFIG.fetch('ab_test_blacklist').include?(current_transaction_simple_id)
  end

  def self.is_missing_experiments?(experiment_selection_hash)
    missing_keys = ::AB_TESTS.keys - experiment_selection_hash.keys
    !missing_keys.empty?
  end

  def self.set_ab_test_cookie(value, cookies)
    cookies[CookieNames::AB_TEST] = { value: value.to_json, expires: 2.weeks.from_now }
  end

  def self.experiment_selections
    AB_TESTS.inject({}) do |hash, (experiment_name, ab_test)|
      hash[experiment_name] = ab_test.get_ab_test_name(rand)
      hash
    end
  end

  def self.update_ab_test_cookie(cookies_hash, cookies)
    new_selections = experiment_selections.merge(cookies_hash)
    set_ab_test_cookie(new_selections, cookies)
  end
end
