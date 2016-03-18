module Display
  class FederationTranslator
    TranslationError = Class.new(StandardError)
    def translate(key, opts = {})
      I18n.t(key, opts.merge({ raise: true }))
    rescue I18n::MissingTranslationData => e
      if I18n.locale != :en
        translate(key, locale: :en)
      else
        raise TranslationError, e
      end
    end
  end
end
