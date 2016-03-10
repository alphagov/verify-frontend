class SSLContextFactory
  def create_context(options = {})
    OpenSSL::SSL::SSLContext.new(:TLSv1_2).tap do |context|
      options.try(:cert_path) do |path|
        context.cert = OpenSSL::X509Certificate.new(path)
      end
    end
  end
end
