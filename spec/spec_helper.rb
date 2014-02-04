$LOAD_PATH.unshift "../lib"

require 'simplecov'
SimpleCov.start do
  add_filter "/spec/"
end if ENV["COVERAGE"]

require 'rspec/given'
require 'vcr'
require 'pry'
require 'timecop'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.mock_with :flexmock
end
