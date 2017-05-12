require 'rails_helper'
require 'controller_helper'

describe WhyCompaniesController do
  subject { get :index, params: { locale: 'en' } }

  it 'renders the certified companies LOA1 template when LEVEL_1 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_1')
    expect(subject).to render_template(:why_companies_LOA1)
    expect(subject).to_not render_template(:why_companies_LOA2)
  end

  it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')
    expect(subject).to render_template(:why_companies_LOA2)
    expect(subject).to_not render_template(:why_companies_LOA1)
  end
end
