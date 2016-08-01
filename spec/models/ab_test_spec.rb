require 'spec_helper'
require 'models/ab_test'

describe ABTest do
  context '#get_ab_test_value' do
    it 'will return logos_yes given an input below 0.75' do
      alternatives = { logos_yes: 75, logos_no: 25 }
      random_number = 0.1
      expect(ABTest.new(alternatives).get_ab_test_cookie(random_number)).to eql('logos_yes')
    end

    it 'will return logos_no given an input above 0.75 but below 1.0' do
      alternatives = { logos_yes: 75, logos_no: 25 }
      random_number = 0.9
      expect(ABTest.new(alternatives).get_ab_test_cookie(random_number)).to eql('logos_no')
    end

    it 'will return logos_yes given a value below 0.99' do
      alternatives = { logos_yes: 99, logos_no: 1 }
      random_number = 0.8
      expect(ABTest.new(alternatives).get_ab_test_cookie(random_number)).to eql('logos_yes')
    end

    it 'will return logos_maybe given an input of 0.99' do
      alternatives = { logos_yes: 33, logos_no: 33, logos_maybe: 33 }
      random_number = 0.99
      expect(ABTest.new(alternatives).get_ab_test_cookie(random_number)).to eql('logos_maybe')
    end

    it 'will return logos_yes given an input of 0.0' do
      alternatives = { logos_yes: 33, logos_no: 33, logos_maybe: 33 }
      random_number = 0.0
      expect(ABTest.new(alternatives).get_ab_test_cookie(random_number)).to eql('logos_yes')
    end
  end
end
