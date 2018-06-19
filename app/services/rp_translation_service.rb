class RpTranslationService
  def initialize(translator)
    @translator = translator
    @locales = %w(en cy)
  end

  def get_transactions
    CONFIG_PROXY.transactions.map do |transaction|
      transaction['simpleId']
    end
  end

  def update_rp_translations(transaction)
    translations = get_translations(transaction, I18n.locale)

    I18n.backend.store_translations(I18n.locale, rps: Hash[transaction, translations])
  end

  def update_rps_translations
    # Get transactions from external endpoint
    # This could use all translations to get a list of transactions,
    # depending on how the returned data is structured.
    transactions = get_transactions

    transactions.each do |transaction|
      @locales.each do |locale|
        translations = get_translations(transaction, locale)

        I18n.backend.store_translations(locale, rps: Hash[transaction, translations])
      end
    end

    if defined? RP_DISPLAY_REPOSITORY
      RP_DISPLAY_REPOSITORY.merge!(
        transaction => Display::RpDisplayData.new(transaction, @translator)
      )
    end
  end

private

  def get_translations(transaction, locale)
    CONFIG_PROXY.get_transaction_translations(transaction, locale)
  end
end
