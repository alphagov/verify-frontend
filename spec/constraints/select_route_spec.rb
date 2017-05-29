require 'rails_helper'
require 'spec_helper'

describe SelectRoute do
  EXPERIMENT_NAME = 'app_transparency'.freeze
  ALTERNATIVE_NAME = "#{EXPERIMENT_NAME}_variant".freeze
  ALTERNATIVE_LOOKUP = "#{EXPERIMENT_NAME}_variant".freeze

  experiment_stub = nil
  select_route = nil
  session = nil

  before(:each) do
    select_route = SelectRoute.new(EXPERIMENT_NAME, 'variant')
  end

  context 'experiment tests' do
    before(:each) do
      session = {}
      experiment_stub = MockExperiment.new
      ab_test_stub = {
          EXPERIMENT_NAME => experiment_stub
      }
      stub_const('AB_TESTS', ab_test_stub)
      allow(AbTest).to receive(:report)
    end

    it 'evaluates true when experiment and route both match' do
      expect(experiment_stub).to receive(:alternative_name).with(ALTERNATIVE_LOOKUP).and_return(ALTERNATIVE_NAME)

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be true
    end

    it 'evaluates false when experiment matches but the route does not' do
      expect(experiment_stub).to receive(:alternative_name).and_return('no_alt_name_found')

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, "non matching route")
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end

    it 'evaluates false when experiment does not match' do
      cookies = create_ab_test_cookie("not matching experiment", nil)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end
  end

  context 'piwik tests' do
    it 'reports to piwik when experiment matches' do
      session = { transaction_simple_id: 'test-rp' }

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)

      allow(AbTest).to receive(:report).with(EXPERIMENT_NAME, ALTERNATIVE_NAME, "test-rp", request)

      select_route.matches?(request)
    end

    it 'does not report to piwik when experiment does not match' do
      session = { transaction_simple_id: 'test-rp' }

      cookies = create_ab_test_cookie('non matching experiment', nil)
      request = RequestStub.new(session, cookies)

      allow(AbTest).to receive(:report).never

      select_route.matches?(request)
    end
  end

private

  class RequestStub
    attr_reader :cookies, :session

    def initialize(session, cookies)
      @session = session
      @cookies = cookies
    end
  end

  class MockExperiment
    def alternative_name(something)
    end
  end

  def create_ab_test_cookie(experiment_name, alternative_name)
    {
        'ab_test' =>
            "{\"#{experiment_name}\": \"#{alternative_name}\"}"
    }
  end
end
