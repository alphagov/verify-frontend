module Feedback
  class DummyZendeskClient
    attr_reader :tickets

    def initialize
      @logger = ::Rails.logger
      @tickets = DummyTicketCollection.new(@logger)
    end
  end

  class DummyTicketCollection
    attr_reader :options

    def initialize(logger)
      @logger = logger
    end

    def create!(options)
      if should_raise_error?(options)
        @logger.info("Simulating Zendesk ticket creation failure: #{options.inspect}")
        raise ZendeskAPI::Error::RecordInvalid.new(body: { "details" => "sample error message from Zendesk" })
      else
        @logger.info("Zendesk ticket created: #{options.inspect}")
        DummyTicket.new
      end
    end

  protected

    def should_raise_error?(options)
      options[:comment][:value] =~ /break_zendesk/
    end
  end

  class DummyTicket
    def id
      4
    end
  end
end
