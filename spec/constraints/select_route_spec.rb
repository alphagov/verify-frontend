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
    # allow(AbTest).to receive(:report)
  end

  context 'experiment tests' do
    before(:each) do
      select_route = SelectRoute.new(EXP_NAME, 'variant')
      session = {}
    end

    it 'evaluates true when experiment and route both match' do
      expect(experiment_stub).to receive(:alternative_name).with(ALTERNATIVE_NAME).and_return(ALTERNATIVE_NAME)

      cookies = create_ab_test_cookie(EXP_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be true
    end

    it 'evaluates false when experiment matches but the route does not' do
      expect(experiment_stub).to receive(:alternative_name).and_return('no_alt_name_found')

      cookies = create_ab_test_cookie(EXP_NAME, "non matching route")
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end

    it 'evaluates false when experiment does not match' do
      cookies = create_ab_test_cookie("not matching experiment", nil)
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end
  end

  context 'reporting' do
    result_string = nil

    before(:each) do
      result_string = 'not used'

      ab_reporter = -> (experiment_name, reported_alternative, transaction_id, request) {
        result_string = "#{experiment_name},#{reported_alternative},#{transaction_id},#{request.to_str}"
      }

      select_route = SelectRoute.new(EXP_NAME, 'variant', ab_reporter)
    end

    it 'execute ab_reporter when experiment matches' do
      expect(experiment_stub).to receive(:alternative_name).with(ALTERNATIVE_NAME).and_return(ALTERNATIVE_NAME)
      session = { transaction_simple_id: 'test-rp' }

      cookies = create_ab_test_cookie(EXP_NAME, ALTERNATIVE_NAME)
      request = RequestStub.new(session, cookies)

      select_route.matches?(request)

      expect(result_string).to eq("#{EXP_NAME},#{ALTERNATIVE_NAME},test-rp,request example")
    end

    it 'does not execute ab_reporter when experiment does not match' do
      session = { transaction_simple_id: 'test-rp' }

      cookies = create_ab_test_cookie('non matching experiment', nil)
      request = RequestStub.new(session, cookies)

      select_route.matches?(request)
      expect(result_string).to eq('not used')
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
