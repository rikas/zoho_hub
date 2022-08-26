# frozen_string_literal: true

module ZohoHub
  class Configuration
    attr_accessor :client_id, :secret, :redirect_uri, :api_domain, :api_version
    attr_writer :debug

    DEFAULT_API_DOMAIN = 'https://accounts.zoho.eu'
    DEFAULT_API_VERSION = 'v2'

    def initialize
      @client_id = ''
      @secret = ''
      @redirect_uri = ''
      @api_domain = DEFAULT_API_DOMAIN
      @api_version = DEFAULT_API_VERSION
    end

    def debug?
      @debug
    end
  end
end
