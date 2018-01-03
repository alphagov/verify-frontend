require 'spec_helper'
require 'rails_helper'

describe 'User encounters an unknown page' do
  it 'will render the 404 page' do
    visit '/404'
    expect(current_path).to eql '/404'
    expect(page).to have_content t('errors.page_not_found.heading')
  end
end
