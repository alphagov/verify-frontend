class RpTranslationService
  def initialize(translator)
    @translator = translator

    update_rp_translations
  end

  def get_transactions
    ['test-rp']
  end

  def update_rp_translations
    # Get transactions from external endpoint
    # This could use all translations to get a list of transactions,
    # depending on how the returned data is structured.
    transactions = get_transactions

    transactions.each do |transaction|
      translations = get_translations(transaction)

      # This is making the assumption that the returned data will be keyed by locale.
      translations.map do |locale, translations_for_locale|
        I18n.backend.store_translations(locale, {
          rps: Hash[transaction, translations_for_locale]
        })
      end

      if defined? RP_DISPLAY_REPOSITORY
        RP_DISPLAY_REPOSITORY.merge!({
          transaction => Display::RpDisplayData.new(transaction, @translator)
        })
      end
    end
  end

  private

  def get_translations(transaction)
    CONFIG_PROXY.get_transaction_translations(transaction)
  end
end