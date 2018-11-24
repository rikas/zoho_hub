# frozen_string_literal: true

require 'backports/2.3.0/hash' if Gem::Version.new(RUBY_VERSION) < Gem::Version.new('2.3.0')

require 'zoho_hub/version'
require 'zoho_hub/auth'
require 'zoho_hub/configuration'
require 'zoho_hub/connection'
require 'zoho_hub/errors'
require 'zoho_hub/records/contact'
require 'zoho_hub/records/potential'
require 'zoho_hub/records/campaign'
require 'zoho_hub/records/account'
require 'zoho_hub/records/quote'
require 'zoho_hub/records/funder'
require 'zoho_hub/records/product'

require 'zoho_hub/settings/fields'
require 'zoho_hub/settings/modules'

module ZohoHub
  module_function

  def configuration
    @configuration ||= Configuration.new
  end

  def connection
    @connection
  end

  def on_refresh(&block)
    @connection.on_refresh_cb = block
  end

  def setup_connection(params = {})
    raise "ERROR: #{params[:error]}" if params[:error]

    connection_params = params.slice(:access_token, :expires_in, :api_domain, :refresh_token)

    @connection = Connection.new(connection_params)
  end

  def refresh_token?
    return false unless connection

    connection.refresh_token?
  end

  def access_token?
    return false unless connection

    connection.access_token?
  end

  def modules
    @modules ||= Settings::Modules.all
  end

  def configure
    yield(configuration)
  end
end
