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
    let(:nullable_attr_form) {
      Class.new(CycleThreeForm) do
        define_method(:pattern) do
          Regexp.new('^[a-z]*$')
        end

        def allows_nullable?
          true
        end
      end
    }

    it 'should be valid when data matches regex' do
      form_class = letters_only_form

      form = form_class.new(cycle_three_data: 'someattribute')

      expect(form).to be_valid
    end

    context "allows nullable" do
      it 'should be valid with null attribute set is true' do
        form_class = nullable_attr_form

        form = form_class.new(cycle_three_data: '12123123123', null_attribute: 'true')
        expect(form).to be_valid
      end

      it 'should be valid with null attribute set is true and cycle three data is empty' do
        form_class = nullable_attr_form

        form = form_class.new(cycle_three_data: '', null_attribute: 'true')
        expect(form).to be_valid
      end

      it 'should not be valid with null attribute is unset' do
        form_class = nullable_attr_form

        form = form_class.new(cycle_three_data: '12123123123')
        expect(form).to_not be_valid
      end

      it 'should not be valid with null attribute is false' do
        form_class = nullable_attr_form

        form = form_class.new(cycle_three_data: '12123123123', null_attribute: 'false')
        expect(form).to_not be_valid
      end
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

      it 'should return empty cycle 3 data if allows nullable and null attribute is true' do
        form_class = nullable_attr_form
        form = form_class.new(cycle_three_data: '12123123123', null_attribute: 'true')

        expect(form.sanitised_cycle_three_data).to eq ''
      end
    end
  end
end
