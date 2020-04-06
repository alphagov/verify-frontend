require 'rails_helper'
require 'spec_helper'

describe SelectRoute do
  EXP_NAME = 'app_transparency'.freeze
  ALTERNATIVE_NAME = "#{EXP_NAME}_variant".freeze

  experiment_stub = nil
  select_route = nil
  session = nil

  before(:each) do
    experiment_stub = MockExperiment.new
    ab_test_stub = {
      EXP_NAME => experiment_stub
    }
    stub_const('AB_TESTS', ab_test_stub)
  end

  context 'experiment tests' do
    before(:each) do
      select_route = SelectRoute.new(EXP_NAME, 'variant')
      session = {}
    end

    it 'evaluates true when experiment and route both match' do
      expect(experiment_stub).to receive(:alternative_name).twice.with(ALTERNATIVE_NAME).and_return(ALTERNATIVE_NAME)

      cookies = create_ab_test_cookie(EXP_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be true
    end

    it 'evaluates false when experiment matches but the route does not' do
      expect(experiment_stub).to receive(:alternative_name).and_return('no_alt_name_found')

      cookies = create_ab_test_cookie(EXP_NAME, 'non matching route')
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end

    it 'evaluates false when experiment does not match' do
      cookies = create_ab_test_cookie('not matching experiment', nil)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end
  end

  context 'reporting for any LOA' do
    before(:each) do
      select_route = SelectRoute.new(EXP_NAME, 'variant')
    end

    it 'executes ab_reporter when experiment matches' do
      expect(experiment_stub).to receive(:alternative_name).with(ALTERNATIVE_NAME).and_return(ALTERNATIVE_NAME)
      session = { transaction_simple_id: 'test-rp', requested_loa: 'anything' }

      cookies = create_ab_test_cookie(EXP_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)
      expect(AbTest).to receive(:report_ab_test_details).with(request, EXP_NAME)

      select_route.matches?(request)
    end

    it 'does not execute ab_reporter when experiment does not match' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'anything' }

      cookies = create_ab_test_cookie('non matching experiment', nil)
      request = RequestStub.new(session, cookies)

      select_route.matches?(request)
      expect(AbTest).not_to receive(:report_ab_test_details)
    end
  end

  context 'reporting for a specific LOA' do
    cookies = nil

    before(:each) do
      expect(experiment_stub).to receive(:alternative_name).with(ALTERNATIVE_NAME).and_return(ALTERNATIVE_NAME)

      cookies = create_ab_test_cookie(EXP_NAME, ALTERNATIVE_NAME)

      select_route = SelectRoute.new(EXP_NAME, 'variant', experiment_loa: 'LEVEL_1')
    end

    it 'executes ab_reporter when LOA matches' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_1' }
      request = RequestStub.new(session, cookies)
      expect(AbTest).to receive(:report_ab_test_details).with(request, EXP_NAME)

      select_route.matches?(request)
    end

    it 'does not execute ab_reporter when experiment does not match' do
      expect(AbTest).not_to receive(:report_ab_test_details)
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_2' }
      request = RequestStub.new(session, cookies)

      select_route.matches?(request)
    end
  end

  context 'controlling ab test trial run' do
    cookies = nil

    it 'evaluates to true when trial_enabled flag is set to true and trial cookie matches experiment' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_1' }

      cookies = create_ab_test_trial_cookie('app_transparency')
      request = RequestStub.new(session, cookies)

      select_route = SelectRoute.new(EXP_NAME, 'variant', trial_enabled: true)

      expect(select_route.matches?(request)).to be true
    end

    it 'evaluates to false when trial_enabled flag is set to false and trial cookie matches experiment' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_1' }

      cookies = create_ab_test_trial_cookie('app_transparency')
      request = RequestStub.new(session, cookies)

      select_route = SelectRoute.new(EXP_NAME, 'variant', trial_enabled: false)

      expect(select_route.matches?(request)).to be false
    end

    it 'evaluates to false when trial_enabled flag is set to true but trial cookie does not match experiment' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_1' }

      cookies = create_ab_test_trial_cookie('wrong one')
      request = RequestStub.new(session, cookies)

      select_route = SelectRoute.new(EXP_NAME, 'variant', trial_enabled: true)

      expect(select_route.matches?(request)).to be false
    end

    it 'evaluates to false when trial_enabled flag is set to true but trial cookie does not exist' do
      session = { transaction_simple_id: 'test-rp', requested_loa: 'LEVEL_1' }

      request = RequestStub.new(session, {})

      select_route = SelectRoute.new(EXP_NAME, 'variant', trial_enabled: true)

      expect(select_route.matches?(request)).to be false
    end
  end

private

  class RequestStub
    attr_reader :cookies, :session

    def initialize(session, cookies)
      @session = session
      @cookies = cookies
    end

    def to_str
      'request example'
    end

    def flash
      {}
    end
  end

  class MockExperiment
    def alternative_name(something); end

    def concluded?; end
  end

  def create_ab_test_cookie(experiment_name, alternative_name)
    {
      'ab_test' =>
          "{\"#{experiment_name}\": \"#{alternative_name}\"}"
    }
  end

  def create_ab_test_trial_cookie(experiment_name)
    {
      'ab_test_trial' =>
          experiment_name
    }
  end
end
