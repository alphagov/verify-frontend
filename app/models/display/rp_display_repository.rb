require 'loading_cache'
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
      LoadingCache.new(display_data, translation_refresh_proc)
    end

    def translation_refresh_proc
      @display_data_refresh_proc ||= ->(display_data) {
        begin
          RP_TRANSLATION_SERVICE.update_rp_translations(display_data.simple_id)
        rescue StandardError => e
          @logger.error(e)
        end
        display_data.tap(&:validate_content!)
      }
    end
  end
end
