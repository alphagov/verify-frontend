require 'analytics/custom_variable'
require 'cookies/cookies'

module AbTest
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
    cookies[CookieNames::AB_TEST] = { value: value.to_json, expires: 1.week.from_now }
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

  def self.report_ab_test_details(request, experiment_name)
    transaction_id = request.session[:transaction_simple_id]

    if experiment_is_valid(transaction_id, experiment_name)
      alternative_name = self.get_alternative_name(request, experiment_name)
      request.session[:ab_test_variant] = alternative_name
      request.flash[:ab_test_variant] = alternative_name
    end
  end

  def self.get_alternative_name(request, experiment_name)
    ab_test = ::AB_TESTS[experiment_name]
    reported_alternative = Cookies.parse_json(request.cookies[CookieNames::AB_TEST])[experiment_name]
    ab_test.alternative_name(reported_alternative)
  end

  def self.experiment_is_valid(transaction_id, experiment_name)
    ab_test = ::AB_TESTS[experiment_name]
    ab_test && !current_transaction_is_excluded_from_ab_test(transaction_id) && !ab_test.concluded?
  end
end
