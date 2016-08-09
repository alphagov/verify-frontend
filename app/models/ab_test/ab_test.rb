module AbTest
  def self.alternative_name_for_experiment(experiment_name, alternative_name, default = nil)
    ab_test = ::AB_TESTS[experiment_name]
    ab_test ? ab_test.alternative_name(alternative_name) : default
  end
end
