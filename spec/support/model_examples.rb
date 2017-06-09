RSpec.shared_examples "delegates to display_data" do |field, klass|
  describe "##{field}" do
    it "returns the display_data #{field}" do
      display_data = double(:display_data)
      expected = 'hi'
      expect(display_data).to receive(field).and_return expected

      subject = Class.new(klass) do
        define_singleton_method(:display_data) do
          display_data
        end
      end

      expect(subject.new({}).public_send(field)).to eql expected
    end
  end
end
