# frozen_string_literal: true

module ZohoHub
  class Configuration
    attr_accessor :client_id, :secret, :redirect_uri, :api_domain
    attr_writer :debug

    DEFAULT_API_DOMAIN = 'https://accounts.zoho.eu'

    def initialize
      @client_id = ''
      @secret = ''
      @redirect_uri = ''
      @api_domain = DEFAULT_API_DOMAIN
    end

    def debug?
      @debug
    end
  end
end
