source 'https://rubygems.org'

# Specify your gem's dependencies in tfs_graph.gemspec
gemspec

group :test do
  gem 'rspec'
  gem 'rspec-given'
  gem 'flexmock'
  gem 'webmock'
  gem 'vcr'
end

group :test, :development do
  gem "pry"
  gem 'benchmark-ips'
  gem 'related'
  gem 'neo4j-core'
  gem 'timecop'
end

gem 'simplecov', :require => false, :group => :test