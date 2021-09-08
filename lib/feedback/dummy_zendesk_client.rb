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
    attr_reader :last

    def initialize(logger)
      @logger = logger
    end

    def create!(options)
      if should_raise_error?(options)
        @logger.info("Simulating Zendesk ticket creation failure: #{options.inspect}")
        raise ZendeskAPI::Error::RecordInvalid.new(body: { details: "sample error message from Zendesk" })
      else
        @logger.info("Zendesk ticket created: #{options.inspect}")
        @last = DummyTicket.new(options)
      end
    end

  protected

    def should_raise_error?(options)
      options[:comment][:value] =~ /break_zendesk/
    end
  end

  class DummyTicket
    def initialize(options)
      @options = options
    end

    def comment
      @options[:comment][:value]
    end

    def id
      4
    end
  end
end
