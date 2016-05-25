RSpec.shared_examples "has content" do |field, klass|
  describe "##{field}" do
    let(:translator) {
      double(:translator)
    }

    subject {
      klass.new('foobar', translator)
    }

    let(:translation_line) {
      "#{subject.prefix}.foobar.#{field}"
    }

    it "returns the localised #{field}" do
      expected = double(field)
      expect(translator).to receive(:translate).with(translation_line).and_return expected
      expect(subject.public_send(field)).to eql expected
    end

    it "will validate content including #{field}" do
      subject = klass.new('foobar', translator)
      allow(translator).to receive(:translate)
      expect(translator).to receive(:translate).with(translation_line)
      subject.validate_content!
    end
  end
end

RSpec.shared_examples "has content with default" do |field, klass|
  include_examples "has content", field, klass

  describe "##{field}" do
    it "will return a default if translation missing" do
      translator = double(:translator)
      subject = klass.new('foobar', translator)
      expect(translator).to receive(:translate).with("#{subject.prefix}.foobar.#{field}").and_raise StandardError
      expect {
        subject.public_send(field)
      }.to_not raise_error
    end
  end
end
