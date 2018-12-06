def env_var_set?
  CONFIG.ab_test_file
end

def build_experiment_hash
  if !env_var_set? then return {}.freeze end

  experiments = YAML.load_file(CONFIG.ab_test_file)['experiments']
  if !experiments then return {}.freeze end

  experiments.inject({}) do |ab_tests, experiment|
    ab_tests[experiment.keys.first] = AbTest::Experiment.new(experiment)
    ab_tests
  end
end

AB_TESTS = build_experiment_hash
