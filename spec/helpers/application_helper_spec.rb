require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  Idp = Struct.new(:display_name, :tagline)

  describe '#idp_tagline' do
    it 'should output name and tagline if tagline is present' do
      idp_tagline = helper.idp_tagline(Idp.new('name', 'tag'))
      expect(idp_tagline).to eq('name: tag')
    end
    it 'should output name if tagline is not present' do
      idp_tagline = helper.idp_tagline(Idp.new('name', nil))
      expect(idp_tagline).to eq('name')
    end
  end
end
