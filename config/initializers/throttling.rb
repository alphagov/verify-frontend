def env_var_set?
  CONFIG.throttling_file
end

def build_logic_hash
  if !env_var_set? then return {}.freeze end

  options = YAML.load_file(CONFIG.throttling_file)
  if !options then return {}.freeze end

  AbTest::Experiment.new(options)
end

THROTTLING = build_logic_hash
