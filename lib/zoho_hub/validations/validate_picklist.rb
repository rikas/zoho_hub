# frozen_string_literal: true

require 'zoho_hub/validations/base_validation'

module ZohoHub
  module Validations
    class ValidatePicklist < BaseValidation
      def validate(options = {})
        value = record.send(field)

        return unless value

        list = options[:list].map { |option| option[:actual_value] }

        return if list.include?(value)

        msg = "has an invalid value `#{value}`. Accepted values: #{list.join(', ')}"
        record.add_error(field, msg)
      end
    end
  end
end
