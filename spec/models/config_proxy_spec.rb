require "rspec"
require "models/config_endpoints"
require "models/config_proxy"

describe "ConfigProxy" do
  let(:api_client) { double(:api_client) }
  let(:config_proxy) { ConfigProxy.new(api_client) }

  describe "get_transaction_by_simple_id" do
    before :each do
      transactions_json = [
          {
              "simpleId" => "test-rp", "serviceHomepage" => "http://localhost:50130/test-rp",
              "loaList" => %w(LEVEL_2), "headlessStartpage" => "http://localhost:50130/success?rp-name=test-rp"
          },
          {
              "simpleId" => "test-rp-noc3", "serviceHomepage" => "http://localhost:50130/test-rp-noc3",
              "loaList" => %w(LEVEL_2), "headlessStartpage" => nil
          },
      ]
      expect(api_client).to receive(:get).with(config_proxy.transactions_endpoint).and_return(transactions_json)
    end

    it "should return the correct RP when valid simpleId passed" do
      rp = config_proxy.get_transaction_by_simple_id("test-rp")

      expect(rp).to include("simpleId" => "test-rp",
                            "serviceHomepage" => "http://localhost:50130/test-rp",
                            "loaList" => %w(LEVEL_2),
                            "headlessStartpage" => "http://localhost:50130/success?rp-name=test-rp")
    end

    it "should return nil when invalid simpleId passed" do
      rp = config_proxy.get_transaction_by_simple_id("non-existent-rp")

      expect(rp).to be_nil
    end
  end
end
