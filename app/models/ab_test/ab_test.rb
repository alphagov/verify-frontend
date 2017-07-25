require 'analytics/custom_variable'

module AbTest
  ACTION_NAME = 'AB test - %s'.freeze

  def self.alternative_name_for_experiment(experiment_name, alternative_name, default = nil)
    ab_test = ::AB_TESTS[experiment_name]
    ab_test ? ab_test.alternative_name(alternative_name) : default
  end

  def self.report(experiment_name, reported_alternative, transaction_id, request)
    ab_test = ::AB_TESTS[experiment_name]
    if ab_test && !current_transaction_is_excluded_from_ab_test(transaction_id) && !ab_test.concluded?
      alternative_name = AbTest.alternative_name_for_experiment(experiment_name, reported_alternative)
      if reported_alternative_matches_an_allowed_alternative(alternative_name, reported_alternative)
        custom_variable = Analytics::CustomVariable.build(:ab_test, alternative_name)
        ANALYTICS_REPORTER.report_custom_variable(request, ACTION_NAME % alternative_name, custom_variable)
      end
    end
  end

  def self.reported_alternative_matches_an_allowed_alternative(alternative_name, reported_alternative)
    alternative_name && alternative_name == reported_alternative
  end

  def self.current_transaction_is_excluded_from_ab_test(current_transaction_simple_id)
    RP_CONFIG.fetch('ab_test_blacklist').include?(current_transaction_simple_id)
  end
end
