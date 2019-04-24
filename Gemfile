# frozen_string_literal: true

source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

group :development do
  gem 'rubocop'
  gem 'rubocop-rspec'
end

group :test do
  gem 'codecov', require: false
  gem 'mongoid'
  gem 'simplecov', require: false
end

# Specify your gem's dependencies in graphql_rails.gemspec
gemspec
