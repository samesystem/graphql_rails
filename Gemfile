# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'rubocop', '0.91.0'
  gem 'rubocop-performance', '~> 1.8', '>= 1.8.1'
  gem 'rubocop-rspec', '~> 1.44', '>= 1.44.1'
end

group :test do
  gem 'codecov', require: false
  gem 'mongoid'
  gem 'simplecov', require: false
end

# Specify your gem's dependencies in graphql_rails.gemspec
gemspec
