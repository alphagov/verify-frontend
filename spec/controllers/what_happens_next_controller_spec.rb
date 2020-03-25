require 'rails_helper'
require 'controller_helper'
require 'api_test_helper'
require 'piwik_test_helper'

describe WhatHappensNextController do
  before(:each) do
    set_session_and_cookies_with_loa('LEVEL_2')
  end

  context 'GET what_happens_next#index' do
    subject { get :index, params: { locale: 'en' } }

    it 'renders what_happens_next page' do
      expect(subject).to render_template(:index)
    end
  end
end
