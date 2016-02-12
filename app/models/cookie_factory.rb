class CookieFactory
  def initialize(is_cookie_secure)
    @is_secure = is_cookie_secure
  end

  def create(cookie_hash)
    result = {}
    cookie_hash.each { |name, value|
      # Default expiry time for cookies in rails is browser session lifetime
      result[name] = { value: value, secure: @is_secure, path: '/', httponly: true }
    }
    result
  end
end
