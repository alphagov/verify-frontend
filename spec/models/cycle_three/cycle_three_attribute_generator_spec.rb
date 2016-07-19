require 'rails_helper'

module CycleThree
  describe CycleThreeAttributeGenerator do
    let(:file_loader) { double(:file_loader) }
    let(:display_data_licence) { double(:display_data_licence) }
    let(:display_data_licence_two) { double(:display_data_licence_two) }
    let(:display_data_ni) { double(:display_data_ni) }
    let(:display_data_repo) {
      {
        "DrivingLicenceNumber" =>    display_data_licence,
        "DrivingLicenceNumberTwo" => display_data_licence_two,
        "NationalInsuranceNumber" => display_data_ni
      }
    }
    let(:cycle_three_attribute_generator) {
      CycleThreeAttributeGenerator.new(file_loader, display_data_repo)
    }

    describe '#attribute_classes_by_name' do
      it 'should load patterns from YAML files' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'length' => 16 },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '.*' }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['NationalInsuranceNumber'].new({}).pattern).to eql(/.*/)
        expect(attribute_classes['DrivingLicenceNumber'].new({}).pattern).to eql(/^abc/)
      end

      it 'should fail to load valid patterns from incomplete YAML files' do
        path = 'bad_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'NationalInsuranceNumber' }
        ])
        expect { cycle_three_attribute_generator.attribute_classes_by_name(path) }
          .to(raise_error CycleThreeAttributeGenerator::MissingDataError) { |error|
            expect(error.message).to eql 'key not found: "pattern"'
          }
      end

      it 'should fail to load invalid regex from YAML files' do
        path = 'invalid_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '[ab' },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '[]' }
        ])
        expect { cycle_three_attribute_generator.attribute_classes_by_name(path) }.to raise_error RegexpError
      end

      it 'should truncate cycle three data if length provided' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'length' => 16 },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '.*' }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['DrivingLicenceNumber'].new(
          cycle_three_data: '123456789012345678'
        ).sanitised_cycle_three_data).to eql('1234567890123456')
      end

      it 'should allow nullable if set' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'nullable' => true }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['DrivingLicenceNumber'].allows_nullable?).to eql true
      end

      it 'should not allow nullable if not set' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'nullable' => false }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['DrivingLicenceNumber'].allows_nullable?).to eql false
      end

      it 'should not override nullable for all generated classes if set for one' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'nullable' => true },
          { 'name' => 'DrivingLicenceNumberTwo', 'pattern' => '^abc', 'nullable' => false }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['DrivingLicenceNumberTwo'].allows_nullable?).to eql false
        expect(attribute_classes['DrivingLicenceNumber'].allows_nullable?).to eql true
      end

      it 'should set display data on all generated classes' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'nullable' => true },
          { 'name' => 'DrivingLicenceNumberTwo', 'pattern' => '^abc', 'nullable' => false }
        ])
        attribute_classes = cycle_three_attribute_generator.attribute_classes_by_name(path)
        expect(attribute_classes['DrivingLicenceNumberTwo'].display_data).to eql display_data_licence_two
        expect(attribute_classes['DrivingLicenceNumber'].display_data).to eql display_data_licence
      end

      it 'should error if can\'t find display data' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'nullable' => true },
          { 'name' => 'DrivingLicenceNumberFoo', 'pattern' => '^abc', 'nullable' => false }
        ])
        expect {
          cycle_three_attribute_generator.attribute_classes_by_name(path)
        }.to raise_error CycleThreeAttributeGenerator::MissingDataError
      end
    end
  end
end
