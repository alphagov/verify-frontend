require "rails_helper"
require "controller_helper"

describe FeedbackController do
  subject { get :index, params: { locale: "en" } }

  context "when feedback flag is true" do
    before(:each) do stub_const("FEEDBACK_DISABLED", true) end

    it "renders feedback disabled view" do
      expect(subject).to render_template(:disabled)
    end
  end

  context "when feedback flag is not present" do
    it "renders feedback form" do
      expect(subject).to render_template(:index)
    end
  end

  context "when feedback flag is false" do
    before(:each) do stub_const("FEEDBACK_DISABLED", false) end
    it "renders feedback form" do
      expect(subject).to render_template(:index)
    end
  end
end
