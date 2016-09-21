FEDERATION_TRANSLATOR = Display::FederationTranslator.new
RP_CONFIG = YAML.load_file(CONFIG.rp_config)
IDP_CONFIG = YAML.load_file(CONFIG.idp_config)
