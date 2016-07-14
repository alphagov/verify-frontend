require 'rails_helper'

module CycleThree
  describe CycleThreeForm do
    let(:letters_only_form) {
      Class.new(CycleThreeForm) do
        define_method(:pattern) do
          Regexp.new('^[a-z]*$')
        end
      end
    }

    it 'should be valid when data matches regex' do
      form_class = letters_only_form

      form = form_class.new(cycle_three_data: 'someattribute')

      expect(form).to be_valid
    end

    it 'should not be valid when data does not match regex' do
      form_class = letters_only_form

      form = form_class.new(cycle_three_data: '123')

      expect(form).to_not be_valid
      expect(form.errors.full_messages).to eql ['Cycle three data hub.further_information.attribute_validation_message']
    end

    describe '#sanitised_cycle_three_data' do
      it 'should return cycle 3 data with whitespace and dashes removed' do
        form_class = letters_only_form

        form = form_class.new(cycle_three_data: " 1-2 3  \n ")

        expect(form.sanitised_cycle_three_data).to eq('123')
      end

      it 'should uppercase cycle 3 data' do
        form_class = letters_only_form

        form = form_class.new(cycle_three_data: 'abc')

        expect(form.sanitised_cycle_three_data).to eq('ABC')
      end
    end
  end
end
