require 'yaml'
require 'idp_eligibility/attribute_masker'
require 'idp_eligibility/evidence'

module IdpEligibility
  class ProfilesLoader
    attr_reader :recommended_profiles
    attr_reader :non_recommended_profiles
    def initialize(profiles_path)
      @profiles_path = profiles_path
      @document_attribute_masker = AttributeMasker.new(Evidence::DOCUMENT_ATTRIBUTES)
    end

    def load
      recommended_profiles = load_profiles("recommended_profiles")
      non_recommended_profiles = load_profiles("non_recommended_profiles")
      all_profiles = merge_profiles(recommended_profiles, non_recommended_profiles)
      document_profiles = apply_documents_mask(all_profiles)
      LoadedProfileFilters.new(
        ProfileFilter.new(recommended_profiles),
        ProfileFilter.new(non_recommended_profiles),
        ProfileFilter.new(all_profiles),
        ProfileFilter.new(document_profiles),
        idps_with_hints
      )
    end

    LoadedProfileFilters = Struct.new(:recommended_profiles, :non_recommended_profiles, :all_profiles, :document_profiles, :idps_with_hints)

  private

    def apply_documents_mask(profiles)
      @document_attribute_masker.mask(profiles)
    end

    def load_profiles(type)
      load_yaml.inject({}) do |profiles, yaml|
        idp_profiles = yaml.fetch(type)
        yaml.fetch('simpleIds').each do |simple_id|
          profiles[simple_id] = idp_profiles.map { |profile| Profile.new(profile) }
        end
        profiles
      end
    end

    def idps_with_hints
      load_yaml.select { |data| data['send_hints'] }.flat_map { |data| data.fetch('simpleIds') }
    end

    def load_yaml
      profile_files = File.join(@profiles_path, '*.yml')
      Dir::glob(profile_files).map do |file|
        YAML::load_file(file)
      end
    end

    def merge_profiles(left_profiles, right_profiles)
      left_profiles.merge(right_profiles) do |_key, left, right|
        left + right
      end
    end
  end
end
