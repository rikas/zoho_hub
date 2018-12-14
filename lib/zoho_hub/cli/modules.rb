# frozen_string_literal: true

require 'launchy'
require 'optparse'

require 'zoho_hub'
require 'zoho_hub/auth'
require 'zoho_hub/oauth_callback_server'

module ZohoHub
  module Cli
    class Modules
      def initialize
        @options = {}
      end

      def parser
        @parser ||= OptionParser.new do |op|
          op.banner = "Usage: #{op.program_name} modules:read -c CLIENT_ID -s SECRET"

          op.on('-c', '--client-id=client_id', 'The Zoho client ID') do |client|
            @options[:client_id] = client
          end

          op.on('-s', '--secret=secret', 'The Zoho secret') do |secret|
            @options[:secret] = secret
          end
        end
      end

      def run(argv = ARGV, env = ENV)
        exit 1 unless good_run(argv, env)
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
