require 'rails_helper'

module CycleThree
  describe CycleThreeFormGenerator do
    let(:file_loader) { double(:file_loader) }
    let(:cycle_three_form_generator) {
      CycleThreeFormGenerator.new(file_loader)
    }

    describe '#form_classes_by_name' do
      it 'should load patterns from YAML files' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'length' => 16 },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '.*' }
        ])
        form_classes = cycle_three_form_generator.form_classes_by_name(path)
        expect(form_classes['NationalInsuranceNumber'].new({}).pattern).to eql(/.*/)
        expect(form_classes['DrivingLicenceNumber'].new({}).pattern).to eql(/^abc/)
      end

      it 'should fail to load valid patterns from incomplete YAML files' do
        path = 'bad_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'NationalInsuranceNumber' }
        ])
        expect { cycle_three_form_generator.form_classes_by_name(path) }
          .to(raise_error CycleThreeFormGenerator::MissingDataError) { |error|
            expect(error.message).to eql 'key not found: "pattern"'
          }
      end

      it 'should fail to load invalid regex from YAML files' do
        path = 'invalid_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '[ab' },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '[]' }
        ])
        expect { cycle_three_form_generator.form_classes_by_name(path) }.to raise_error RegexpError
      end

      it 'should truncate cycle three data if length provided' do
        path = 'good_attributes_path'
        expect(file_loader).to receive(:load).with(path).and_return([
          { 'name' => 'DrivingLicenceNumber', 'pattern' => '^abc', 'length' => 16 },
          { 'name' => 'NationalInsuranceNumber', 'pattern' => '.*' }
        ])
        form_classes = cycle_three_form_generator.form_classes_by_name(path)
        expect(form_classes['DrivingLicenceNumber'].new(
          cycle_three_data: '123456789012345678'
        ).sanitised_cycle_three_data).to eql('1234567890123456')
      end
    end
  end
end
