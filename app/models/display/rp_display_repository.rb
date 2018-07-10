module Display
  class RpDisplayRepository
    def initialize(translator)
      @translator = translator
      @display_data = {}
    end

    def update_translations(simple_id)
      if @display_data.empty?
        transactions = RP_TRANSLATION_SERVICE.transactions
        transactions.each do |transaction|
          RP_TRANSLATION_SERVICE.update_rp_translations(transaction)
          create_display_data(transaction)
        end
      else
        RP_TRANSLATION_SERVICE.update_rp_translations(simple_id)
      end
    end

    def get_translations(transaction_simple_id)
      unless @display_data.key?(transaction_simple_id)
        create_display_data(transaction_simple_id)
      end

      @display_data.fetch(transaction_simple_id)
    end

  private

    def create_display_data(simple_id)
      display_data = Display::RpDisplayData.new(simple_id, @translator)
      display_data.validate_content!
      @display_data[simple_id] = display_data
    end
  end
end
