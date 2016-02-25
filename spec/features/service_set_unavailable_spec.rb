require 'feature_helper'

describe 'service reports the on service status', type: :request do
  it "is OK when ZDD_LATCH doesn't exist" do
    response = get('/service-status')
    expect(response).to eql 200
  end

  it "is not OK when ZDD_LATCH does exist" do
    file = Tempfile.new('zdd_file')
    expect(ENV).to receive(:fetch).with("ZDD_LATCH").twice.and_return(file.path)
    response = get('/service-status')
    expect(response).to eql 503
    expect(@response.headers["Connection"]).to eql "close"
  end
end
