require "loading_cache"
module Display
  class RpDisplayRepository
    def initialize(translator, logger)
      @translator = translator
      @logger = logger
      @store = Concurrent::Map.new
    end

    def get_translations(transaction_simple_id)
      find_or_create(transaction_simple_id).fetch do
        create_display_data(transaction_simple_id)
      end
    end

  private

    def find_or_create(simple_id)
      @store.compute_if_absent(simple_id) do
        LoadingCache.new
      end
      @store[simple_id]
    end

    def create_display_data(simple_id)
      begin
        RP_TRANSLATION_SERVICE.update_rp_translations(simple_id)
      rescue StandardError => e
        @logger.error(e)
      end
      Display::RpDisplayData.new(simple_id, @translator).tap(&:validate_content!)
    end
  end
end
