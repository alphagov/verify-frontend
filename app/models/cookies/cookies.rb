module Cookies
  def self.parse_json(cookie)
    begin
      hash = MultiJson.load(cookie)
    rescue MultiJson::ParseError, TypeError => e
      Rails.logger.debug("Cookie contains invalid JSON #{e}")
      hash = {}
    end
    hash
  end
end
