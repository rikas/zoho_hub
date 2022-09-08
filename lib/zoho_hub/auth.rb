# frozen_string_literal: true

require 'multi_json'
require 'faraday'
require 'faraday_middleware'
require 'addressable'

module ZohoHub
  # Class that takes care of authentication using Oauth2 workflow as described here:
  # https://www.zoho.com/crm/help/api/v2/#oauth-request.
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
      ZohoCRM.notifications.all
    ].freeze

    DEFAULT_ACCESS_TYPE = 'offline'

    def_delegators :@configuration, :redirect_uri, :client_id, :secret, :api_domain

    def initialize(access_type: DEFAULT_ACCESS_TYPE, scopes: DEFAULT_SCOPES)
      @configuration = ZohoHub.configuration
      @access_type = access_type
      @scopes = scopes
    end

    def self.auth_url(access_type: DEFAULT_ACCESS_TYPE, scopes: DEFAULT_SCOPES)
      new(access_type: access_type, scopes: scopes).auth_url
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
      Addressable::URI.join(api_domain, AUTH_PATH)
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

    def token_full_uri
      Addressable::URI.join(api_domain, TOKEN_PATH)
    end

    def revoke_refresh_token(refresh_token)
      uri = token_full_uri

      uri.query_values = { token: refresh_token }

      url = Addressable::URI.unencode(uri.to_s)

      result = Faraday.post(url)

      parse(result.body)
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

      uri.query_values = {
        client_id: client_id,
        client_secret: secret,
        code: grant_token,
        redirect_uri: redirect_uri,
        grant_type: 'authorization_code'
      }

      Addressable::URI.unencode(uri.to_s)
    end

    private

    def parse(body)
      MultiJson.load(body, symbolize_keys: true)
    end
  end
end
