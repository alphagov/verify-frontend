require 'rails_helper'

module CycleThree
  describe CycleThreeAttribute do
    let(:letters_only_form) {
      Class.new(CycleThreeAttribute) do
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

    it 'should not allow nullable fields by default' do
      form_class = letters_only_form

      form = form_class.new(cycle_three_data: '123')

      expect(form.allows_nullable?).to eql false
    end

    describe '#allows_nullable?' do
      it 'should delegate to its class method called ::allows_nullable?' do
        form_class = Class.new(CycleThreeAttribute)
        form_class_instance = form_class.new({})
        expected_result_from_class = double('expected')
        expect(form_class).to receive(:allows_nullable?).and_return(expected_result_from_class)
        expect(form_class_instance.allows_nullable?).to eq(expected_result_from_class)
      end
    end

    describe '#display_data' do
      it 'should delegate to its class method called ::display_data' do
        form_class = Class.new(CycleThreeAttribute)
        form_class_instance = form_class.new({})
        expected_result_from_class = double('expected')
        expect(form_class).to receive(:display_data).and_return(expected_result_from_class)
        expect(form_class_instance.display_data).to eq(expected_result_from_class)
      end
    end

    describe '#sanitised_cycle_three_data' do
      it 'should return cycle 3 data with only letters and numbers' do
        form_class = letters_only_form

        form = form_class.new(cycle_three_data: " 1-2 3  \n ?%")

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
