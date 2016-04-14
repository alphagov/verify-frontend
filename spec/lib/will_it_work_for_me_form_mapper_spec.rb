require 'spec_helper'
require 'will_it_work_for_me_form_mapper'

describe WillItWorkForMeFormMapper do
  it 'maps old frontend form parameters to new front parameters' do
    params = { 'above_age_threshold' => 'true', 'resident_last_12_months' => 'true' }
    actual = WillItWorkForMeFormMapper.map(params)
    expect(actual).to eql(params)
  end

  it 'uses will_it_work_for_me_form fields from new frontend when they exist' do
    params = { 'will_it_work_for_me_form' => { 'above_age_threshold' => 'true', 'resident_last_12_months' => 'true' } }
    actual = WillItWorkForMeFormMapper.map(params)
    expected = { 'above_age_threshold' => 'true', 'resident_last_12_months' => 'true' }
    expect(actual).to eql(expected)
  end
end
