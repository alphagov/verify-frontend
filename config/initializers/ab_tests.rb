experiments = CONFIG.ab_test_file ? YAML.load_file(CONFIG.ab_test_file).fetch('experiments', {}) : {}
ab_tests = experiments.inject({}) do |hash, experiment|
  hash[experiment.keys.first] = AbTest::Experiment.new(experiment)
  hash
end
AB_TESTS = ab_tests.freeze
