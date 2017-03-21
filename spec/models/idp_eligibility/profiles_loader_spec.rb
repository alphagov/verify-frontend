require 'spec_helper'
require 'idp_eligibility/profile_filter'
require 'idp_eligibility/profiles_loader'
require 'idp_eligibility/profile'

module IdpEligibility
  describe ProfilesLoader do
    let(:file_loader) { double(:file_loader) }
    let(:profiles_loader) {
      ProfilesLoader.new(file_loader)
    }
    let(:good_profiles) {
      [
        {
          'simpleIds' => %w(example-idp example-idp-stub),
          'recommended_profiles' => [%w(passport driving_licence)],
          'non_recommended_profiles' => [%w(passport mobile_phone)]
        },
        {
          'simpleIds' => ['example-idp-two'],
          'recommended_profiles' => [%w(passport driving_licence)],
          'non_recommended_profiles' => [],
          'demo_profiles' => [%w(non_uk_id_document mobile_phone)]
        }
      ]
    }

    describe '#load' do
      it 'should load recommended profiles from YAML files' do
        path = 'good_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return(good_profiles)
        evidence = [Profile.new(%i(passport driving_licence))]
        profiles_repository = ProfileFilter.new(
          'example-idp' => evidence,
          'example-idp-two' => evidence,
          'example-idp-stub' => evidence
        )
        expect(profiles_loader.load(path).recommended_profiles).to eq(profiles_repository)
      end

      it 'should load non recommended profiles from YAML files' do
        path = 'good_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return(good_profiles)
        evidence = [Profile.new(%i(passport mobile_phone))]
        profiles_repository = ProfileFilter.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [],
        )
        expect(profiles_loader.load(path).non_recommended_profiles).to eq(profiles_repository)
      end

      it 'should load demo profiles from YAML files' do
        path = 'good_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return(good_profiles)
        evidence = [Profile.new(%i(non_uk_id_document mobile_phone))]
        profiles_repository = ProfileFilter.new(
          'example-idp' => [],
          'example-idp-stub' => [],
          'example-idp-two' => evidence,
        )
        expect(profiles_loader.load(path).demo_profiles).to eq(profiles_repository)
      end

      it 'should load all profiles from YAML files' do
        path = 'good_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return(good_profiles)
        evidence = [Profile.new(%i{passport driving_licence}), Profile.new(%i(passport mobile_phone))]
        profiles_repository = ProfileFilter.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [Profile.new(%i{passport driving_licence}), Profile.new(%i(non_uk_id_document mobile_phone))]
        )
        expect(profiles_loader.load(path).all_profiles).to eq(profiles_repository)
      end

      it 'should supply a seperate repository of document profiles' do
        path = 'good_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return(good_profiles)
        evidence = [Profile.new(%i{passport driving_licence}), Profile.new(%i(passport))]
        profiles_repository = ProfileFilter.new(
          'example-idp' => evidence,
          'example-idp-stub' => evidence,
          'example-idp-two' => [Profile.new(%i{passport driving_licence}), Profile.new(%i(non_uk_id_document))]
        )
        expect(profiles_loader.load(path).document_profiles).to eq(profiles_repository)
      end

      it 'should raise an error when expected keys are missing from yaml' do
        path = 'bad_profiles_path'
        bad_profiles = [
          {
            'simpleIds' => ['example-idp'],
            'blah' => [%w(passport driving_licence)]
          }]
        expect(file_loader).to receive(:load).with(path).and_return(bad_profiles)

        expect {
          profiles_loader.load(path)
        }.to raise_error KeyError
      end

      it 'should throw exception when no yaml files found' do
        path = 'empty_profiles_path'
        expect(file_loader).to receive(:load).with(path).and_return([])

        expect { profiles_loader.load(path) }.to raise_error("No profiles found at #{path}")
      end
    end
  end
end
