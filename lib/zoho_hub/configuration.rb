# frozen_string_literal: true

module ZohoHub
  class Configuration
    attr_accessor :client_id, :secret, :redirect_uri, :base_url, :access_type
    attr_writer :debug

    DEFAULT_BASE_URL = 'https://accounts.zoho.eu'

    def initialize
      @client_id = ''
      @secret = ''
      @redirect_uri = ''
      @base_url = DEFAULT_BASE_URL
      @access_type = Auth::DEFAULT_ACCESS_TYPE
    end

    def debug?
      @debug
    end
  end
end
