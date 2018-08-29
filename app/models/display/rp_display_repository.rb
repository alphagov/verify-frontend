require 'concurrent'
require 'date'
module Display
  class RpDisplayRepository
    def initialize(translator, logger)
      @translator = translator
      @logger = logger
      @store = Concurrent::Map.new
    end

    def get_translations(transaction_simple_id)
      find_or_create(transaction_simple_id).fetch!
    end

  private

    def find_or_create(simple_id)
      @store[simple_id] ||= create_display_data(simple_id)
    end

    def create_display_data(simple_id)
      display_data = Display::RpDisplayData.new(simple_id, @translator)
      DisplayDataCache.new(display_data, @logger)
    end

    class DisplayDataCache
      include Concurrent::Async
      def initialize(display_data, logger)
        @last_updated = :never
        @display_data = display_data
        @logger = logger
      end

      def fetch!
        result = self.await.fetch_display_data!
        if(result.fulfilled?)
          return result.value
        else
          raise result.reason
        end
      end

      def fetch_display_data!
        if need_to_fetch_upstream?
          fetch_upstream!
        end
        @display_data
      end

    private

      def fetch_upstream!
        begin
          RP_TRANSLATION_SERVICE.update_rp_translations(@display_data.simple_id)
        rescue StandardError => e
          @logger.error(e)
        end
        @display_data.validate_content!
        @last_updated = DateTime.now
      end

      def need_to_fetch_upstream?
        never_updated? || expired?
      end

      def never_updated?
        @last_updated == :never
      end

      def expired?
        (@last_updated + lifetime).to_datetime < DateTime.now
      end

      def lifetime
        @lifetime ||= 30.minutes
      end
    end
  end
end
