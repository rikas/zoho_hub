# frozen_string_literal: true

require 'launchy'
require 'optparse'

require 'zoho_hub'
require 'zoho_hub/oauth_callback_server'

module ZohoHub
  module Cli
    class Server
      def initialize
        @options = {}
      end

      def parser
        @parser ||= OptionParser.new do |op|
          op.banner = "Usage: #{op.program_name} server -c CLIENT_ID -s SECRET [options]"

          op.on('-c', '--client-id=client_id', 'The Zoho client ID') do |client|
            @options[:client_id] = client
          end

          op.on('-s', '--secret=secret', 'The Zoho secret') do |secret|
            @options[:secret] = secret
          end

          op.on('-p', '--port=port', "The port for your callback (#{default_port})") do |port|
            @options[:port] = port
          end
        end
      end

      def default_port
        ZohoHub::OauthCallbackServer.settings.port
      end

      def run(argv = ARGV, env = ENV)
        exit 1 unless good_run(argv, env)

        ZohoHub::OauthCallbackServer.set(:port, @options[:port]) if @options[:port]

        callback_path = ZohoHub::OauthCallbackServer::CALLBACK_PATH
        bind_port = ZohoHub::OauthCallbackServer.settings.port
        bind_address = ZohoHub::OauthCallbackServer.settings.bind

        callback_url = "http://#{bind_address}:#{bind_port}/#{callback_path}"

        puts "Callback URL: #{callback_url}"

        ZohoHub.configure do |config|
          config.client_id    = @options[:client_id]
          config.secret       = @options[:secret]
          config.redirect_uri = callback_url
        end

        url = ZohoHub::Auth.auth_url
        Launchy.open(url)

        puts "Running callback server...."
        ZohoHub::OauthCallbackServer.run!
      end

      def good_run(argv, env)
        return false unless parse(argv, env)

        true
      end

      def parse(argv, env)
        parser.parse!(argv)
        true
      rescue OptionParser::ParseError => error
        error_output(error)
      end

      def error_output(error)
        $stderr.puts "Error: #{error}"
        $stderr.puts "Try `#{parser.program_name} server --help' for more information"

        false
      end
    end
  end
end
