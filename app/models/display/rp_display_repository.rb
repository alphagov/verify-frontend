module Display
  class RpDisplayRepository
    def initialize(translator)
      @translator = translator
      @display_data = {}
    end

    def get_translations(transaction_simple_id)
      unless @display_data.has_key?(transaction_simple_id)
        display_data = Display::RpDisplayData.new(transaction_simple_id, @translator)
        display_data.validate_content!
        @display_data[transaction_simple_id] = display_data
      end

      @display_data.fetch(transaction_simple_id)
    end
  end
end
