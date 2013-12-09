source 'https://rubygems.org'

# Specify your gem's dependencies in tfs_graph.gemspec
gemspec

gem "related", git: "https://github.com/plukevdh/related.git", branch: "preserve_external_ids"

group :test do
  gem 'rspec'
  gem 'rspec-given'
  gem 'webmock'
  gem 'vcr'
  gem 'factory_girl'
end

group :test, :development do
  gem "pry"
  gem 'benchmark-ips'
end