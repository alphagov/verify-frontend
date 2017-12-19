require 'idp_recommendations/idp_rules'

class IdpProfilesLoader
  def initialize(yaml_loader)
    @yaml_loader = yaml_loader
  end

  def parse_config_files(idp_rules_directory)
    idps_rules = @yaml_loader.load(idp_rules_directory)

    parsed_rules = {}
    idps_rules.each do |idp|
      get_idp_names(idp).each do |idp_name|
        parsed_rules[idp_name] = get_idp_rules(idp)
      end
    end
    parsed_rules
  end

private

  def get_idp_names(idp)
    idp['simpleIds']
  end

  def get_idp_rules(idp)
    IdpRules.new(idp)
  end
end
