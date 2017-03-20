module Support
  module Raven
    class Logger < ::Logger
      def initialize
        super(nil)
        @formatter = RavenFormatter.new
        @logdev = RavenWriter.new
      end

      def add(severity, _exception = nil, _progname = nil, &block)
        if severity >= ::Logger::ERROR
          super
        end
        true
      end

      # A Formatter which returns an exception if its there
      class RavenFormatter < ::Logger::Formatter
        # This method is invoked when a log event occurs
        def call(_severity, _timestamp, _progname, msg)
          case msg
          when ::Exception
            msg
          when String
            msg
          else
            msg.inspect
          end
        end
      end

      class RavenWriter
        def write(msg = nil)
          unless msg.nil? || message_is_404?(msg) || message_is_raven_log?(msg)
            ::Raven.capture_exception(msg)
          end
        end

        def message_is_404?(message)
          message.is_a?(ActionController::RoutingError) ||
            (
              # 404 messages (and all exceptions) are currently being logged in
              # DebugExceptions across multiple log messages so we need to do
              # some filtering here to ignore each message
              # https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/middleware/debug_exceptions.rb#L169
              message.is_a?(String) &&
                (
                   # A message declaring the type of 404 error
                   message.start_with?("ActionController::RoutingError") ||
                   # Some whitespace that gets added
                   message == "  " ||
                   # The start of the 404 backtrace trace
                   message.start_with?("lib/store_session_id.rb:11:in `call'")
                )
            )
        end

        def message_is_raven_log?(message)
          message.is_a?(String) && message.start_with?(::Raven::Logger::LOG_PREFIX)
        end
      end
    end
  end
end
