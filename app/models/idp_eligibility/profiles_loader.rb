require 'yaml_loader'
require 'idp_eligibility/attribute_masker'
require 'idp_eligibility/evidence'

module IdpEligibility
  class ProfilesLoader
    attr_reader :recommended_profiles
    attr_reader :non_recommended_profiles
    def initialize(file_loader)
      @file_loader = file_loader
      @document_attribute_masker = AttributeMasker.new(Evidence::DOCUMENT_ATTRIBUTES)
    end

    def load(path)
      profiles = @file_loader.load(path)
      if profiles.empty?
        raise "No profiles found at #{path}"
      end

      recommended_profiles = select_profiles(profiles, "recommended_profiles")
      non_recommended_profiles = select_profiles(profiles, "non_recommended_profiles")
      demo_profiles = select_profiles(profiles, "demo_profiles") { [] }
      all_profiles = merge_profiles(merge_profiles(recommended_profiles, non_recommended_profiles), demo_profiles)
      document_profiles = apply_documents_mask(all_profiles)
      document_profiles_b = apply_documents_mask(recommended_profiles)
      LoadedProfileFilters.new(
        ProfileFilter.new(recommended_profiles),
        ProfileFilter.new(non_recommended_profiles),
        ProfileFilter.new(demo_profiles),
        ProfileFilter.new(all_profiles),
        ProfileFilter.new(document_profiles),
        ProfileFilter.new(document_profiles_b)
      )
    end

    LoadedProfileFilters = Struct.new(:recommended_profiles, :non_recommended_profiles, :demo_profiles, :all_profiles, :document_profiles, :document_profiles_b)

  private

    def apply_documents_mask(profiles)
      @document_attribute_masker.mask(profiles)
    end

    def select_profiles(profiles, type, &blk)
      profiles.inject({}) do |selected_profiles, yaml|
        idp_profiles = yaml.fetch(type, &blk)
        yaml.fetch('simpleIds').each do |simple_id|
          selected_profiles[simple_id] = idp_profiles.map { |profile| Profile.new(profile) }
        end
        selected_profiles
      end
    end

    def merge_profiles(left_profiles, right_profiles)
      left_profiles.merge(right_profiles) do |_key, left, right|
        left + right
      end
    end
  end
end
