# frozen_string_literal: true

require 'bundler/setup'
require 'simplecov'
SimpleCov.start

require 'dotenv'
Dotenv.load

require 'zoho_hub'

ZohoHub.configure do |config|
  config.client_id    = ENV['ZOHO_CLIENT_ID']
  config.secret       = ENV['ZOHO_SECRET']
  config.redirect_uri = ENV['ZOHO_REDIRECT_URI']
end

token_params = ZohoHub::Auth.refresh_token(ENV['ZOHO_REFRESH_TOKEN'])
ZohoHub.setup_connection(token_params)

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
end

require 'vcr'

VCR.configure do |config|
  config.cassette_library_dir = 'spec/cassettes'
  config.hook_into :webmock
  config.filter_sensitive_data('<TOKEN>') do
    token_params[:access_token]
  end
end
