module Display
  class RepositoryFactory
    def initialize(translator, yaml_loader)
      @translator = translator
      @yaml_loader = yaml_loader
    end

    def create_idp_repository(directory)
      create_from_directory(Display::IdpDisplayData, directory)
    end

    def create_country_repository(directory)
      create_from_directory(Display::CountryDisplayData, directory)
    end

    def create_eidas_scheme_repository(directory)
      create_without_translation(directory, Display::EidasSchemeDisplayData)
    end

    def create_rp_repository
      RpTranslationRepository.new(@translator)
    end

    def create_cycle_three_repository(directory)
      create_from_directory(Display::CycleThreeDisplayData, directory)
    end

  private

    def create(klass, simple_ids)
      display_data_collection = simple_ids.map do |simple_id|
        klass.new(simple_id, @translator)
      end

      display_data_collection.each(&:validate_content!)
      display_data_collection.inject({}) do |hash, data|
        hash[data.simple_id] = data
        hash
      end
    end

    def create_from_directory(klass, directory)
      simple_ids = Dir[File.join(directory, "*.yml").to_s].map do |file|
        File.basename(file, ".yml")
      end

      create(klass, simple_ids)
    end

    def create_without_translation(directory, klass)
      loaded_data = @yaml_loader.load_with_id(directory).map do |file, data|
        [file, klass.new(file, data)]
      end
      loaded_data.to_h
    end
  end
end
