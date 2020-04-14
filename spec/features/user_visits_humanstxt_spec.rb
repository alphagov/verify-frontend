require "feature_helper"

RSpec.describe "user visits humans.txt" do
  it "will tell humans how to work at GOV.UK Verify" do
    visit("/humans.txt")

    expect(page.body).to eql "GOV.UK Verify is built by a team at the Government Digital Service in London. If you'd like to join us, see https://identityassurance.blog.gov.uk/work-with-us/"
  end
end
