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
  gem "related", git: "https://github.com/plukevdh/related.git", branch: "namespace_fix"
  gem 'timecop'

  platforms :jruby do
    # gem 'neo4j-core', git: 'https://github.com/andreasronge/neo4j-core.git'
    gem 'neo4j-core', path: "../neo4j-core"
    gem 'neo4j-community'
  end
end

gem 'simplecov', :require => false, :group => :test