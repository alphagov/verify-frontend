require "idp_configuration/idp_feature_flags_checker"

module IdpConfiguration
  class IdpFeatureFlagsLoader
    def initialize(file_loader)
      @file_loader = file_loader
    end

    def load(path, flags)
      profiles = @file_loader.load(path)

      feature_flags_for_idps = flags.map do |flag|
        [flag, idps_with_flag_set(profiles, flag.to_s)]
      end

      IdpConfiguration::IdpFeatureFlagsChecker.new(feature_flags_for_idps.to_h)
    end

  private

    def idps_with_flag_set(profiles, flag)
      profiles.select { |data| data[flag] }.flat_map { |data| data.fetch("simpleIds") }
    end
  end
end
