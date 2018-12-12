module Api
  class UpstreamError < StandardError
    attr_reader :hub_type

    def initialize(hub_type = nil)
      @hub_type = hub_type
    end
  end
end
