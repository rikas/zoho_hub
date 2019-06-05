# frozen_string_literal: true

require 'zoho_hub/validations/base_validation'

module ZohoHub
  module Validations
    class ValidateLength < BaseValidation
      def validate(options = {})
        value = record.send(field)

        return unless value

        return if value.size <= options[:length]

        record.add_error(field, 'is too long')
      end
    end
  end
end
