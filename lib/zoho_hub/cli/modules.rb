# frozen_string_literal: true

require 'optparse'
require 'fileutils'
require 'json'

require 'zoho_hub'
require 'zoho_hub/settings/module'

module ZohoHub
  module Cli
    class Modules
      def initialize
        @options = {}
      end

      def parser
        @parser ||= OptionParser.new do |op|
          op.banner = "Usage: #{op.program_name} read-modules -c CLIENT_ID -s SECRET"

          op.on('-c', '--client-id=client_id', 'The Zoho client ID') do |client|
            @options[:client_id] = client
          end

          op.on('-s', '--secret=secret', 'The Zoho secret') do |secret|
            @options[:secret] = secret
          end

          op.on('-r', '--refresh-token=token', 'Your refresh token') do |refresh|
            @options[:refresh_token] = refresh
          end
        end
      end

      def run(argv = ARGV, env = ENV)
        exit 1 unless good_run(argv, env)

        setup_connection

        client_id = @options[:client_id] || ENV['ZOHO_CLIENT_ID']
        puts "Reading modules for client ID: #{client_id}..."

        modules_hashes = ZohoHub::Settings::Module.all_json

        puts "Found #{modules_hashes.size} modules"

        modules_hashes.each do |hash|
          puts "- Caching configuration for #{hash[:plural_label]}"
          cache_module_info(hash)
        end
      end

      def good_run(argv, env)
        return false unless parse(argv, env)

        true
      end

      def setup_connection
        ZohoHub.configure do |config|
          config.client_id    = @options[:client_id] || ENV['ZOHO_CLIENT_ID']
          config.secret       = @options[:secret] || ENV['ZOHO_SECRET']
        end

        refresh_token = @options[:refresh_token] || ENV['ZOHO_REFRESH_TOKEN']
        token_params = ZohoHub::Auth.refresh_token(refresh_token)
        ZohoHub.setup_connection(token_params)
      end

      def cache_module_info(info)
        modules_path = File.join(ZohoHub.root, 'cache', 'modules')
        FileUtils.mkdir_p(modules_path)
        file_name = File.join(modules_path, "#{info[:api_name]}.json")

        File.open(file_name, 'w') do |file|
          file.write(JSON.pretty_generate(info))
        end

        return unless info[:api_supported]

        cache_module_fields(info)
      end

      def cache_module_fields(info)
        fields_array = ZohoHub::Settings::Field.all_json_for(info[:api_name])
        fields_path = File.join(ZohoHub.root, 'cache', 'fields')
        FileUtils.mkdir_p(fields_path)
        file_name = File.join(fields_path, "#{info[:api_name]}.json")

        File.open(file_name, 'w') do |file|
          file.write(JSON.pretty_generate(fields_array))
        end
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
