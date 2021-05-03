# frozen_string_literal: true

require 'backports/2.3.0/hash' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.3.0')
require 'backports/2.5.0/hash' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.5.0')

require 'zoho_hub/version'
require 'zoho_hub/auth'
require 'zoho_hub/configuration'
require 'zoho_hub/connection'
require 'zoho_hub/errors'
require 'zoho_hub/base_record'
require 'zoho_hub/modules/attachment'
require 'zoho_hub/settings/module'

require 'zoho_hub/reflection/module_builder'

require 'multi_json'

module ZohoHub
  module_function

  def root
    File.expand_path(File.join(__dir__, '..'))
  end

  def configuration
    @configuration ||= Configuration.new
  end

  def configure
    yield(configuration)
  end

  # Callback for when the token is refreshed.
  def on_refresh(&block)
    @connection.on_refresh_cb = block
  end

  def setup_connection(params = {})
    raise "ERROR: #{params[:error]}" if params[:error]

    connection_params = params.dup.slice(:access_token, :expires_in, :api_domain, :refresh_token)

    @connection = Connection.new(**connection_params)
  end

  def connection
    @connection
  end

  def refresh_token?
    return false unless connection

    connection.refresh_token?
  end

  def access_token?
    return false unless connection

    connection.access_token?
  end
end
