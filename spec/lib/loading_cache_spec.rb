require "spec_helper"
require "loading_cache"

RSpec.describe LoadingCache, type: :lib do
  it "should call refresh_proc when accessing object from cache for first time" do
    cache = LoadingCache.new
    refreshed_object = double(:refreshed_object)
    expect(cache.fetch { refreshed_object }).to eql refreshed_object
  end

  it "should not update a translations when translations were recently cached" do
    cache = LoadingCache.new
    refreshed_object = double(:refreshed_object)
    expect(cache.fetch { refreshed_object }).to eql refreshed_object
    expect(cache.fetch { :something_else }).to eql refreshed_object
  end

  it "should propogate refresh errors if they occur" do
    error = StandardError.new("Bad Display Data")
    cache = LoadingCache.new
    expect { cache.fetch { raise error } }.to raise_error error
  end

  it "should refresh translations upstream when past lifetime" do
    expect(DateTime).to receive(:now).and_return(31.minutes.ago, 15.minutes.ago, DateTime.now, DateTime.now)
    first_refeshed_object = double(:first_refeshed_object)
    second_refeshed_object = double(:second_refeshed_object)
    cache = LoadingCache.new
    expect(cache.fetch { first_refeshed_object }).to eql first_refeshed_object
    expect(cache.fetch { second_refeshed_object }).to eql first_refeshed_object
    expect(cache.fetch { second_refeshed_object }).to eql second_refeshed_object
  end
end
