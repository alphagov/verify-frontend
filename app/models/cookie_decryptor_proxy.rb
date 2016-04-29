class CookieDecryptorProxy
  def initialize(api_client)
    @api_client = api_client
  end

  def decrypt(cookie)
    @api_client.get('/decrypt_cookie', cookies: cookie)
  end
end
