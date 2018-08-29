class RpTranslationService
  def initialize
    @locales = %w[en cy]
  end

  def transactions
    CONFIG_PROXY.transactions.map do |transaction|
      transaction['simpleId']
    end
  end

  def update_rp_translations(transaction)
    @locales.each do |locale|
      translations = get_translations(transaction, locale)
      I18n.backend.store_translations(locale, rps: Hash[transaction, translations]) unless translations.empty?
    end
  end

private

  def get_translations(transaction, locale)
    CONFIG_PROXY.get_transaction_translations(transaction, locale)
  end
end
