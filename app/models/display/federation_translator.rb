module Display
  class FederationTranslator
    TranslationError = Class.new(StandardError)
    def translate(key)
      I18n.translate(key, raise: true)
    rescue I18n::MissingTranslationData => e
      raise TranslationError, e
    end
  end
end
