$LOAD_PATH.unshift "../lib"

require 'rspec/given'
require 'vcr'
require 'factory_girl'
require 'pry'

FactoryGirl.definition_file_paths = %w{./factories ./spec/factories}
FactoryGirl.find_definitions

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.mock_with :flexmock
  config.include FactoryGirl::Syntax::Methods
end
