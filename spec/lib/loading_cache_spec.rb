require 'spec_helper'
require 'loading_cache'

RSpec.describe LoadingCache, type: :lib do
  it 'should call refresh_proc when accessing object from cache for first time' do
    object = double(:object)
    refresh_proc = double(:refresh_proc)
    cache = LoadingCache.new(object, refresh_proc)
    refreshed_object = double(:refreshed_object)
    expect(refresh_proc).to receive(:call).with(object).and_return(refreshed_object)
    expect(cache.fetch!).to eql refreshed_object
  end

  it 'should not update a translations when translations were recently cached' do
    object = double(:object)
    refresh_proc = double(:refresh_proc)
    cache = LoadingCache.new(object, refresh_proc)
    refreshed_object = double(:refreshed_object)
    expect(refresh_proc).to receive(:call).with(object).and_return(refreshed_object).once
    expect(cache.fetch!).to eql refreshed_object
    expect(cache.fetch!).to eql refreshed_object
  end

  it 'should propogate refresh errors if they occur' do
    error = StandardError.new("Bad Display Data")
    object = double(:object)
    refresh_proc = double(:refresh_proc)
    expect(refresh_proc).to receive(:call).and_raise(error)
    cache = LoadingCache.new(object, refresh_proc)
    expect { cache.fetch! }.to raise_error error
  end

  it 'should refresh translations upstream when past lifetime' do
    expect(DateTime).to receive(:now).and_return(31.minutes.ago, 15.minutes.ago, DateTime.now, DateTime.now)
    object = double(:object)
    refresh_proc = double(:refresh_proc)
    cache = LoadingCache.new(object, refresh_proc)
    refreshed_object = double(:refreshed_object)
    expect(refresh_proc).to receive(:call).and_return(object, refreshed_object).twice
    expect(cache.fetch!).to eql object
    expect(cache.fetch!).to eql object
    expect(cache.fetch!).to eql refreshed_object
  end
end
