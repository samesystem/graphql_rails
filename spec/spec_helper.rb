# frozen_string_literal: true

require 'bundler/setup'
require 'graphql_rails'
require 'pry'

if ENV['CODECOV_TOKEN'] && RUBY_VERSION.start_with?(File.read('.ruby-version')[/^\d\.\d/])
  require 'simplecov'
  require 'codecov'

  SimpleCov.start do
    enable_coverage :branch
    add_filter(/_spec.rb\Z/)
  end

  SimpleCov.formatter = SimpleCov::Formatter::Codecov
end

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
  end

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
