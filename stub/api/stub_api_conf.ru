Dir.chdir(File.dirname(__FILE__))
$LOAD_PATH << File.dirname(__FILE__)
require 'stub_api'

run StubApi
