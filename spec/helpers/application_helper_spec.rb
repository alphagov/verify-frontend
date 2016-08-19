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

  describe '#button_link_to' do
    it 'should pass through the text and path to link_to' do
      button = helper.button_link_to 'My text', '/my_path'
      expect(button).to include('href="/my_path"')
      expect(button).to include('My text')
    end
    it 'should always have a class and role of "button"' do
      button = helper.button_link_to '', ''
      expect(button).to include('class="button"')
      expect(button).to include('role="button"')
    end
    it 'should append "button" to existing classes' do
      button = helper.button_link_to '', '', class: 'test'
      expect(button).to include('class="test button"')
    end
    it 'should overwrite existing roles with "button"' do
      button = helper.button_link_to '', '', role: 'test'
      expect(button).to include('role="button"')
      expect(button).not_to include('role="test"')
    end
  end
end
