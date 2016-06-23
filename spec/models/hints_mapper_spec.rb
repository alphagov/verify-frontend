require 'spec_helper'
require 'models/hints_mapper'

describe HintsMapper do
  it 'should produce a list of hints from answers hash' do
    answers_hash = {
      phone: { 'mobile_phone' => true, 'smart_phone' => false, 'landline' => true },
      documents: { 'passport' => true, 'driving_licence' => true, 'non_uk_id_document' => false }
    }

    hints = HintsMapper.map_answers_to_hints(answers_hash)

    expect(hints).to eql(%w(has_ukpassport has_ukphotolicence not_nonukid not_apps has_mobile has_landline).to_set)
  end

  it 'should ignore unknown evidences' do
    answers_hash = { phone: { dummy_evidence: true } }

    hints = HintsMapper.map_answers_to_hints(answers_hash)

    expect(hints).to be_empty
  end

  it 'should handle an empty answers hash' do
    answers_hash = {}

    hints = HintsMapper.map_answers_to_hints(answers_hash)

    expect(hints).to be_empty
  end
end
