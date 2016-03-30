require 'yaml'

module IdpEligibility
  class RulesLoader
    def self.load(rules_path)
      rules = {}
      rules_files = File.join(rules_path, '*.yml')
      Dir::glob(rules_files) do |file|
        yaml = YAML::load_file(file)
        rules[yaml.fetch('simpleId')] = yaml.fetch('rules')
      end
      rules
    end
  end
end
