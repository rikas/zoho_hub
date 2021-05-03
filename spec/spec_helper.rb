# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'webmock/rspec'
require 'dotenv'
Dotenv.load

require 'zoho_hub'

ZohoHub.configure do |config|
  config.client_id    = ENV['ZOHO_CLIENT_ID']
  config.secret       = ENV['ZOHO_SECRET']
  config.redirect_uri = ENV['ZOHO_REDIRECT_URI']
end

ZohoHub.setup_connection(access_token: ENV['ZOHO_ACCESS_TOKEN'],
                         refresh_token: ENV['ZOHO_REFRESH_TOKEN'],
                         expires_in: ENV['ZOHO_EXPIRES_IN'],
                         api_domain: ENV['ZOHO_API_DOMAIN'] || 'https://crmsandbox.zoho.eu')

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end
