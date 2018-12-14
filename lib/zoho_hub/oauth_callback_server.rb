# frozen_string_literal: true

require 'sinatra/base'

module ZohoHub
  class OauthCallbackServer < Sinatra::Base
    enable :logging

    CALLBACK_PATH = 'oauth2callback'

    get "/#{CALLBACK_PATH}" do
      grant_token = params[:code]

      # This will trigger a post request to get both the token and the refresh token
      @variables = ZohoHub::Auth.get_token(grant_token)

      puts "Variables: #{@variables.inspect}"

      erb :variables
    end
  end
end
