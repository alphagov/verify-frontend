module Api
  class UpstreamError < Api::Error
    attr_reader :hub_type

    def initialize(hub_type = nil)
      @hub_type = hub_type
    end
  end
end
