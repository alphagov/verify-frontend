require 'rails_helper'

module CycleThree
  describe CycleThreeFormGenerator do
    def fixtures(data = '')
      File.join('spec', 'fixtures', data)
    end

    describe '#form_classes_by_name' do
      it 'should load patterns from YAML files' do
        path = fixtures('good_attributes')
        form_classes = CycleThreeFormGenerator.new.form_classes_by_name(path)
        expect(form_classes['NationalInsuranceNumber'].new({}).pattern).to eql(/.*/)
        expect(form_classes['DrivingLicenceNumber'].new({}).pattern).to eql(/^abc/)
      end

      it 'should fail to load valid patterns from incomplete YAML files' do
        path = fixtures('bad_attributes')
        expect { CycleThreeFormGenerator.new.form_classes_by_name(path) }
          .to(raise_error CycleThreeFormGenerator::MissingDataError) { |error|
            expect(error.message).to eql 'key not found: "pattern"'
          }
      end

      it 'should fail to load invalid regex from YAML files' do
        path = fixtures('invalid_attributes')
        expect { CycleThreeFormGenerator.new.form_classes_by_name(path) }.to raise_error RegexpError
      end
    end
  end
end
