# frozen_string_literal: true

require 'zoho_hub/validations/validate_length'
require 'zoho_hub/validations/validate_picklist'

module ZohoHub
  module WithValidations
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def add_validation(field, params = {})
        @validations ||= []

        options = params.dup
        validate = options.delete(:validate)

        unless validate
          raise ArgumentError, 'You must provide the validation with the `validate` key!'
        end

        @validations << { field: field, validate: validate }.merge(options)
      end

      def validations
        @validations || []
      end
    end

    def validate!
      @errors = []

      self.class.validations.each { |validation| validate_field!(validation) }

      @errors
    end

    def errors
      @errors
    end

    def validate_field!(params = {})
      options = params.dup
      validate = options.delete(:validate)

      validator = Module.const_get("Validations::Validate#{validate.downcase.capitalize}")
      validator.new(self, options[:field]).validate(options)
    end

    def add_error(field, message)
      @errors << { field: field, message: message }
    end
  end

  class ValidationError < StandardError
    attr_reader :record

    def initialize(record)
      @record = record
      errors = @record.errors.join(', ')

      super(errors)
    end
  end
end
