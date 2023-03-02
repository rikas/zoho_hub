# frozen_string_literal: true

require 'multi_json'
require 'faraday'
require 'addressable'

module ZohoHub
  class Auth
    extend Forwardable

    TOKEN_PATH = '/oauth/v2/token'
    REVOKE_TOKEN_PATH = '/oauth/v2/token/revoke'
    AUTH_PATH = '/oauth/v2/auth'

    DEFAULT_SCOPES = %w[
      ZohoCRM.modules.custom.all
      ZohoCRM.settings.all
      ZohoCRM.modules.contacts.all
      ZohoCRM.modules.all
    ].freeze

    DEFAULT_ACCESS_TYPE = 'offline'

    def_delegators :@configuration, :redirect_uri, :client_id, :secret

    def initialize(access_type: nil, scopes: nil)
      @configuration = ZohoHub.configuration
      @access_type = access_type || ZohoHub.configuration.access_type
      @scopes = scopes || DEFAULT_SCOPES
    end

    def self.auth_url
      new.auth_url
    end

    def auth_url
      uri = auth_full_uri

      query = {
        client_id: client_id,
        scope: @scopes.join(','),
        access_type: @access_type,
        redirect_uri: redirect_uri,
        response_type: 'code'
      }

      # The consent page must be presented otherwise we don't get the refresh token back.
      query[:prompt] = 'consent' if @access_type == DEFAULT_ACCESS_TYPE

      uri.query_values = query

      Addressable::URI.unencode(uri.to_s)
    end

    def auth_full_uri
      Addressable::URI.join(@configuration.base_url, AUTH_PATH)
    end

    def self.refresh_token(refresh_token)
      new.refresh_token(refresh_token)
    end

    def refresh_token(refresh_token)
      result = Faraday.post(refresh_url(refresh_token))

      json = parse(result.body)
      json.merge(refresh_token: refresh_token)
    end

    def refresh_url(refresh_token)
      uri = token_full_uri

      uri.query_values = {
        client_id: client_id,
        client_secret: secret,
        refresh_token: refresh_token,
        grant_type: 'refresh_token'
      }

      Addressable::URI.unencode(uri.to_s)
    end

    def parse(body)
      MultiJson.load(body, symbolize_keys: true)
    end

    def token_full_uri
      Addressable::URI.join(@configuration.base_url, TOKEN_PATH)
    end

    def revoke_refresh_token(refresh_token)
      uri = revoke_token_full_uri

      uri.query_values = { token: refresh_token }

      url = Addressable::URI.unencode(uri.to_s)

      result = Faraday.post(url)

      parse(result.body)
    end

    def revoke_token_full_uri
      Addressable::URI.join(@configuration.base_url, REVOKE_TOKEN_PATH)
    end

    def self.get_token(grant_token)
      new.get_token(grant_token)
    end

    def get_token(grant_token)
      result = Faraday.post(token_url(grant_token))

      parse(result.body)
    end

    def token_url(grant_token)
      uri = token_full_uri

      query = {
        client_id: client_id,
        client_secret: secret,
        code: grant_token,
        redirect_uri: redirect_uri,
        grant_type: 'authorization_code'
      }

      uri.query_values = query

      Addressable::URI.unencode(uri.to_s)
    end
  end
end
