class SSLContextFactory
  def create_context
    OpenSSL::SSL::SSLContext.new.tap do |context|
      context.set_params(ssl_version: :TLSv1_2)
      context.ciphers = ['DHE-RSA-AES128-GCM-SHA256']
      context.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
  end
end
