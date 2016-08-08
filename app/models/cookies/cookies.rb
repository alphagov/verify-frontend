module Cookies
  def self.parse_json(cookie)
    begin
      hash = JSON.parse(cookie)
    rescue JSON::ParserError, TypeError => e
      Rails.logger.debug("Cookie contains invalid JSON #{e}")
      hash = {}
    end
    hash
  end
end
