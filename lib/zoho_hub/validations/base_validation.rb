# frozen_string_literal: true

module ZohoHub
  module Validations
    class BaseValidation
      attr_accessor :record, :field

      def initialize(record, field)
        @record = record
        @field = field
      end
    end
  end
end
