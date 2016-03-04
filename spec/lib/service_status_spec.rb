require 'spec_helper'
require 'tempfile'
require 'service_status'
describe ServiceStatus do
  it "is availble when zdd file doesn't exist" do
    file = Tempfile.new
    path = file.path
    file.unlink
    stub_const("CONFIG", double(:config, zdd_file: path))
    expect(ServiceStatus.unavailable?).to eql false
  end

  it "is availble when zdd file does exist" do
    file = Tempfile.new
    path = file.path
    stub_const("CONFIG", double(:config, zdd_file: path))
    expect(ServiceStatus.unavailable?).to eql true
  end
end
