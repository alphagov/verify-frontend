require 'rails_helper'
require 'spec_helper'
require 'models/ab_test/ab_test'

describe SelectRoute do

  EXPERIMENT_NAME = 'select_phone_v2'

  experiment_stub = nil
  ab_test_stub = nil

  # let(:piwik_double) { double(:AbTest) }

  before(:each) do
    experiment_stub = MockExperiment.new()
    ab_test_stub = {
        EXPERIMENT_NAME => experiment_stub
    }
    stub_const('AB_TESTS', ab_test_stub)
  end

  context 'experiment tests' do

    it 'determines that experiment and route exist' do
      expect(experiment_stub).to receive(:alternative_name).with('select_phone_v2_variant').and_return('select_phone_v2_variant')

      select_route = SelectRoute.new(EXPERIMENT_NAME, 'variant')

      session = {
          'transaction_simple_id' => 'test-rp'
      }

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, "select_phone_v2_variant")
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be true
    end

    it 'determines that experiment exist but the route does not' do
      expect(experiment_stub).to receive(:alternative_name).and_return('no_alt_name_found')

      select_route = SelectRoute.new(EXPERIMENT_NAME, 'variant')

      session = {
          'transaction_simple_id' => 'test-rp'
      }

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, "some_route")
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end

    it 'determines that experiment does not exist' do
      select_route = SelectRoute.new(EXPERIMENT_NAME, 'variant')

      session = {
          'transaction_simple_id' => 'test-rp'
      }

      cookies = create_ab_test_cookie("unrelated_experiment", "some_route")
      request = RequestStub.new(session, cookies)

      expect(select_route.matches?(request)).to be false
    end
  end

  context 'piwik tests' do

    it 'reports to piwik' do
      select_route = SelectRoute.new(EXPERIMENT_NAME, 'variant')
      session = {
          'transaction_simple_id' => 'test-rp'
      }

      cookies = create_ab_test_cookie(EXPERIMENT_NAME, "select_phone_v2_variant")
      request = RequestStub.new(session, cookies)

      allow(AbTest).to receive(:report).with(EXPERIMENT_NAME, "select_phone_v2_variant", "test-rp", request)

      select_route.matches?(request)
    end
  end

  class RequestStub
    def initialize(session, cookies)
      @session = session
      @cookies = cookies
    end

    def cookies
      @cookies
    end

    def session
      @session
    end
  end

  class MockExperiment
    def alternative_name(something)
    end
  end

  private

  def create_ab_test_cookie(experiment_name, alternative_name)
    {
        'ab_test' =>
            "{\"#{experiment_name}\": \"#{alternative_name}\"}"
    }
  end

end
