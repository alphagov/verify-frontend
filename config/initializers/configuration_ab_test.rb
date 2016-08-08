# Construct a hash of experiment name to AbTest object
AB_TESTS = YAML.load_file(CONFIG.ab_test_file)['experiments'].inject({}) do |ab_tests, experiment|
  ab_tests[experiment.keys.first] = AbTest.new(experiment)
  ab_tests
end
