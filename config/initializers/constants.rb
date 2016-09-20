FINGERPRINT_CONFIG = '/assets2/fp.gif'.freeze
SESSION_VALIDATOR = SessionValidator.new(Integer(CONFIG.session_cookie_duration))
SAML_PROXY_HOST = CONFIG.saml_proxy_host
METADATA_CLIENT = MetadataClient.new(SAML_PROXY_HOST)
