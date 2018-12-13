require 'idp_recommendations/idp_profiles_loader'

describe 'Idp Profiles Loader' do
  let(:yaml_loader) { double('yaml_loader') }
  let(:idp_one) {
    {
        'simpleIds' => %w(idp_one),
        'segments' => {
            'protected' => {
                'recommended' => ['SEGMENT 1'],
                'unlikely' => ['SEGMENT 2'],
            },
            'non_protected' => {
                'recommended' => ['SEGMENT 1', 'SEGMENT 3'],
                'unlikely' => ['SEGMENT 4'],
            }
        },
        'capabilities' => [
            %w(passport)
        ]
    }
  }
  let(:idp_two) {
    {
        'simpleIds' => %w(idp_two idp_two_alternative_name),
        'segments' => {
            'protected' => {
                'recommended' => ['SEGMENT 1', 'SEGMENT 4'],
                'unlikely' => ['SEGMENT 5'],
            },
            'non_protected' => {
                'recommended' => ['SEGMENT 7'],
                'unlikely' => [],
            }
        },
        'capabilities' => [
            %w(passport driving_licence)
        ]
    }
  }

  before(:each) do
    @profiles_loader = IdpProfilesLoader.new(yaml_loader)
  end

  it 'should load all segments defined in the idp rules directory' do
    idp_rules_dir = 'path/to/idp_rules'
    allow(yaml_loader).to receive(:load).with(idp_rules_dir).and_return([idp_one, idp_two])

    idp_rules = @profiles_loader.parse_config_files(idp_rules_dir)

    expect(idp_rules['idp_one'].recommended_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 1'])
    expect(idp_rules['idp_one'].recommended_segments(TransactionGroups::NON_PROTECTED)).to eql(['SEGMENT 1', 'SEGMENT 3'])
    expect(idp_rules['idp_one'].unlikely_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 2'])
    expect(idp_rules['idp_one'].unlikely_segments(TransactionGroups::NON_PROTECTED)).to eql(['SEGMENT 4'])
    expect(idp_rules['idp_one'].capabilities).to eql([%w(passport)])

    expect(idp_rules['idp_two'].recommended_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 1', 'SEGMENT 4'])
    expect(idp_rules['idp_two'].recommended_segments(TransactionGroups::NON_PROTECTED)).to eql(['SEGMENT 7'])
    expect(idp_rules['idp_two'].unlikely_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 5'])
    expect(idp_rules['idp_two'].unlikely_segments(TransactionGroups::NON_PROTECTED)).to eql([])
    expect(idp_rules['idp_two'].capabilities).to eql([%w(passport driving_licence)])

    expect(idp_rules['idp_two_alternative_name'].recommended_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 1', 'SEGMENT 4'])
    expect(idp_rules['idp_two_alternative_name'].recommended_segments(TransactionGroups::NON_PROTECTED)).to eql(['SEGMENT 7'])
    expect(idp_rules['idp_two_alternative_name'].unlikely_segments(TransactionGroups::PROTECTED)).to eql(['SEGMENT 5'])
    expect(idp_rules['idp_two_alternative_name'].unlikely_segments(TransactionGroups::NON_PROTECTED)).to eql([])
    expect(idp_rules['idp_two_alternative_name'].capabilities).to eql([%w(passport driving_licence)])
  end
end
