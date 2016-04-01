require 'yaml'

module IdpEligibility
  class RulesLoader
    def self.load(rules_path)
      rules = {}
      rules_files = File.join(rules_path, '*.yml')
      Dir::glob(rules_files) do |file|
        yaml = YAML::load_file(file)
        idp_rules = yaml.fetch('rules')
        yaml.fetch('simpleIds').each do |simple_id|
          rules[simple_id] = idp_rules
        end
      end
      rules
    end
  end
end
