module SamlProxyEndpoints
  COUNTRY_AUTHN_RESPONSE_ENDPOINT = '/SAML2/SSO/API/RECEIVER/EidasResponse/POST'.freeze

  PARAM_SAML_REQUEST = 'samlRequest'.freeze
  PARAM_RELAY_STATE = 'relayState'.freeze
  PARAM_IP_SEEN_BY_FRONTEND = 'principalIpAsSeenByFrontend'.freeze
end
