require 'rails_helper'
require 'controller_helper'

describe WhyCompaniesLoa2Controller do
  subject { get :index, params: { locale: 'en' } }

  it 'renders the certified companies LOA2 template when LEVEL_2 is the requested LOA' do
    set_session_and_cookies_with_loa('LEVEL_2')
    expect(subject).to render_template(:why_companies_LOA2)
  end
end
