# frozen_string_literal: true

require 'zoho_hub/with_connection'
require 'zoho_hub/with_attributes'

module ZohoHub
  module Settings
    class Field
      include WithConnection
      include WithAttributes

      REQUEST_PATH = 'settings/fields'

      attributes :custom_field, :lookup, :convert_mapping, :visible, :field_label, :length,
                 :view_type, :read_only, :api_name, :unique, :data_type, :formula, :currency, :id,
                 :decimal_place, :pick_list_values, :auto_number

      def self.all_for(module_name)
        fields = all_json_for(module_name)
        fields.map { |json| new(json) }
      end

      def self.all_json_for(module_name)
        response = get(REQUEST_PATH, module: module_name)
        response[:fields]
      end

      def initialize(json = {})
        attributes.each { |attr| send("#{attr}=", json[attr]) }
      end
    end
  end
end
