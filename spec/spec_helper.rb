$LOAD_PATH.unshift "../lib"

require 'related'
require 'rspec/given'
require 'vcr'
require 'pry'

VCR.configure do |c|
  c.cassette_library_dir = 'spec/fixtures/vcr_cassettes'
  c.hook_into :webmock
  c.allow_http_connections_when_no_cassette = true
  c.default_cassette_options = { record: :new_episodes }
  c.configure_rspec_metadata!
end

RSpec.configure do |config|
  config.mock_with :flexmock

  config.before(:each) do
    TFSGraph.config do |c|
      c.tfs = {
        username: 'BFGCOM\apiservice',
        password: "BFGservice123",
        endpoint: "https://tfs-dev-01.bfgdev.inside/RAI"
      }
      c.redis = "localhost:6379/test"
    end
  end

  config.after(:each) do
    r = Related.redis
    r.keys.each do |key|
      r.del key
    end
  end
end
