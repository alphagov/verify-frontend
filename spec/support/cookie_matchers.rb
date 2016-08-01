RSpec::Matchers.define :have_a_signed_value_of do |expected|
  match do |actual|
    cookie = CGI.unescape(actual)
    config = Rails.application.config
    secrets = Rails.application.secrets

    encrypted_signed_cookie_salt = config.action_dispatch.signed_cookie_salt # "signed encrypted cookie" by default

    key_generator = ActiveSupport::KeyGenerator.new(secrets.secret_key_base, iterations: 1000)
    sign_secret = key_generator.generate_key(encrypted_signed_cookie_salt)

    serializer = ActionDispatch::Cookies::JsonSerializer

    verifier = ActiveSupport::MessageVerifier.new(sign_secret, serializer: serializer)
    expected == verifier.verify(cookie)
  end
end
