module Display
  class IdentityProviderDisplayDecorator
    def initialize(translator, logo_directory, white_logo_directory)
      @translator = translator
      @logo_directory = logo_directory
      @white_logo_directory = white_logo_directory
    end

    def decorate_collection(idp_list)
      # We need to randomise the order of IDPs so that it satisfies the need for us to be unbiased in displaying the IDPs.
      idp_list.map { |idp| correlate_display_data(idp) }.select(&:viewable?).shuffle
    end

    def decorate(idp)
      correlate_display_data(idp)
    end

  private

    def correlate_display_data(idp)
      simple_id = idp.simple_id
      logo_path = File.join(@logo_directory, "#{simple_id}.png")
      white_logo_path = File.join(@white_logo_directory, "#{simple_id}.png")
      name = @translator.translate("idps.#{simple_id}.name")
      about = @translator.translate("idps.#{simple_id}.about")
      requirements = @translator.translate("idps.#{simple_id}.requirements")
      special_no_docs_instructions = decorate_special_no_docs_instructions(simple_id)
      no_docs_requirement = decorate_no_docs_requirement(simple_id)
      ViewableIdentityProvider.new(idp, name, logo_path, white_logo_path, about, requirements, special_no_docs_instructions, no_docs_requirement)
    rescue FederationTranslator::TranslationError => e
      Rails.logger.error(e)
      NotViewableIdentityProvider.new(idp)
    end

    def decorate_special_no_docs_instructions(simple_id)
      @translator.translate("idps.#{simple_id}.special_no_docs_instructions_html")
    rescue FederationTranslator::TranslationError
      ''
    end

    def decorate_no_docs_requirement(simple_id)
      @translator.translate("idps.#{simple_id}.no_docs_requirement")
    rescue FederationTranslator::TranslationError
      ''
    end
  end
end
