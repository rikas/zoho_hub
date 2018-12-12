# frozen_string_literal: true

require 'zoho_hub/string_utils'

module ZohoHub
  class ModuleBuilder
    class << self
      def build_from_cache
        cached_module_definitions.map do |file|
          json = MultiJson.load(File.read(file), symbolize_keys: true)

          create_module_class(json)
        end
      end

      def cached_module_definitions
        Dir[File.join(ZohoHub.root, 'cache', 'modules', '**')]
      end

      def create_module_class(json)
        fields = cached_module_fields(json[:api_name])

        klass = Class.new(ZohoHub::BaseRecord) do
          request_path json[:api_name]

          translations = { id: :id }
          fields.each do |field|
            key = StringUtils.underscore(field[:api_name])

            translations[key] = field[:api_name]
          end

          if translations.any?
            attributes(*translations.keys)
            attribute_translation(translations)
          end

          def initialize(params)
            attributes.each do |attr|
              zoho_key = attr_to_zoho_key(attr)

              send("#{attr}=", params[zoho_key] || params[attr])
            end
          end
        end

        ZohoHub.const_set(StringUtils.camelize(json[:singular_label]), klass)
      end

      def cached_module_fields(module_name)
        file = File.join(ZohoHub.root, 'cache', 'fields', "#{module_name}.json")

        return [] unless File.exist?(file)

        json_content = File.read(file)

        MultiJson.load(json_content, symbolize_keys: true)
      end
    end
  end
end
