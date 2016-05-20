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
        def write(exception = nil)
          unless exception.nil? || exception.is_a?(ActionController::RoutingError)
            ::Raven.capture_exception(exception)
          end
        end
      end
    end
  end
end
