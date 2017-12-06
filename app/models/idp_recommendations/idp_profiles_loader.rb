require 'idp_recommendations/idp_rules'

class IdpProfilesLoader
  def initialize(yaml_loader)
    @yaml_loader = yaml_loader
  end

  def parse_config_files(idp_rules_directory)
    idps_rules = @yaml_loader.load(idp_rules_directory)
    idps_rules
        .map { |idp| [get_idp_name(idp), get_idp_rules(idp)] }
        .to_h
  end

private

  def get_idp_name(idp)
    idp['simpleIds'][0]
  end

  def get_idp_rules(idp)
    IdpRules.new(idp)
  end
end
