module Display
  class RpDisplayRepository
    def initialize(translator)
      @translator = translator
      @display_data = {}
    end

    def update_all_translations
      if @display_data.empty?
        transactions = RP_TRANSLATION_SERVICE.get_transactions
        transactions.each do |transaction|
          update_display_data(transaction)
        end
      end
    end

    def get_translations(transaction_simple_id)
      unless @display_data.has_key?(transaction_simple_id)
        update_display_data(transaction_simple_id)
      end

      @display_data.fetch(transaction_simple_id)
    end

  private

    def update_display_data(simple_id)
      display_data = Display::RpDisplayData.new(simple_id, @translator)
      display_data.validate_content!
      @display_data[simple_id] = display_data
    end
  end
end
