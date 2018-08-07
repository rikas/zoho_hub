# frozen_string_literal: true

require 'active_support/core_ext/object/blank'
require 'active_support/core_ext/string/inflections'

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
    return false unless connection.present?

    connection.refresh_token?
  end

  def access_token?
    return false unless connection.present?

    connection.access_token?
  end

  def configure
    yield(configuration)
  end
end
