require "spec_helper"
require "display/rp_display_repository"
require "display/rp_display_data"
require "rp_translation_service"
require "loading_cache"

module Display
  describe RpDisplayRepository do
    let(:translator) { double("I18n") }
    let(:logger) { double(:logger) }
    let(:rp_display_repo) { RpDisplayRepository.new(translator, logger) }
    let(:rp_translation_service) { instance_double("RpTranslationService") }
    before(:each) do
      allow(translator).to receive(:translate!).and_return("")
      stub_const("RP_TRANSLATION_SERVICE", rp_translation_service)
    end

    it "should fetch translations when fetching new display data" do
      expect(rp_translation_service).to receive(:update_rp_translations).with("test-rp").once
      display_data = rp_display_repo.get_translations("test-rp")
      expect(display_data).to be_a(Display::RpDisplayData)
    end

    it "should not update a translations when translations were recently cached" do
      expect(rp_translation_service).to receive(:update_rp_translations).with("test-rp").once
      display_data = rp_display_repo.get_translations("test-rp")
      expect(display_data).to be_a(Display::RpDisplayData)
      expect(rp_display_repo.get_translations("test-rp")).to be display_data
    end

    it "should not propogate upstream errors, but log, when display_data is valid" do
      expect(translator).to receive(:translate!).and_return("")
      error = StandardError.new("FOOBAR")
      expect(logger).to receive(:error).with(error)
      expect(rp_translation_service).to receive(:update_rp_translations).and_raise(error)
      expect { rp_display_repo.get_translations("test-rp") }.to_not raise_error
    end

    it "should propogate upstream errors when display_data is invalid" do
      error = StandardError.new("Bad Display Data")
      expect(translator).to receive(:translate!).and_raise(error)
      expect(rp_translation_service).to receive(:update_rp_translations)
      expect { rp_display_repo.get_translations("test-rp") }.to raise_error error
    end

    it "should refresh translations upstream when past lifetime" do
      expect(DateTime).to receive(:now).and_return(31.minutes.ago, 15.minutes.ago, DateTime.now, DateTime.now)
      expect(rp_translation_service).to receive(:update_rp_translations).with("test-rp").twice
      rp_display_repo.get_translations("test-rp")
      rp_display_repo.get_translations("test-rp")
      rp_display_repo.get_translations("test-rp")
    end
  end
end
