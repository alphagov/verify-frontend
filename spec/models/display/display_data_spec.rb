require 'spec_helper'
require 'display/display_data'

module Display
  describe DisplayData do
    let(:translator) { double(:translator) }

    describe "::prefix" do
      it 'defines the prefix to the localisation key' do
        derived_class = Class.new(Display::DisplayData) do
          prefix :bob
        end
        expect(derived_class.new('simpleid', translator).prefix).to eql :bob
      end
    end

    describe "::content" do
      it "adds a localizable field" do
        derived_class = Class.new(Display::DisplayData) do
          prefix :foo
          content :bob
        end
        expect(translator).to receive(:translate).with('foo.simpleid.bob').and_return 'foobar'
        expect(derived_class.new('simpleid', translator).bob).to eql 'foobar'
      end

      it 'will raise an error when prefix is undefined' do
        derived_class = Class.new(Display::DisplayData) do
          content :bob
        end
        expect {
          derived_class.new('simpleid', double(:translator)).bob
        }.to raise_error NotImplementedError
      end

      it 'will allow default values if translation is not found' do
        derived_class = Class.new(Display::DisplayData) do
          prefix :foo
          content :bob, default: 'foobarbaz'
        end
        expect(translator).to receive(:translate).with('foo.simpleid.bob').and_raise
        expect(derived_class.new('simpleid', translator).bob).to eql 'foobarbaz'
      end

      it 'content will not be shared between derived classes' do
        derived_class_one = Class.new(Display::DisplayData) do
          prefix :foo
          content :bob
        end

        derived_class_two = Class.new(Display::DisplayData) do
          prefix :foo
          content :baz
        end
        expect(derived_class_one.localizable_fields).to_not eql derived_class_two.localizable_fields
      end
    end
  end
end
