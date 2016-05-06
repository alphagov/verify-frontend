require 'ostruct'
require 'rails_helper'

RSpec.describe ApplicationHelper, type: :helper do
  describe '#idp_tagline' do
    it 'should output name and tagline if tagline is present' do
      idp_tagline = helper.idp_tagline(OpenStruct.new('display_name' => 'name', 'tagline' => 'tag'))
      expect(idp_tagline).to eq('name: tag')
    end
    it 'should output name if tagline is not present' do
      idp_tagline = helper.idp_tagline(OpenStruct.new('display_name' => 'name', 'tagline' => nil))
      expect(idp_tagline).to eq('name')
    end
  end
end
