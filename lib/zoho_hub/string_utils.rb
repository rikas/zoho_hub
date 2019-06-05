# frozen_string_literal: true

module ZohoHub
  class StringUtils
    class << self
      def demodulize(text)
        text.split('::').last
      end

      def pluralize(text)
        if ENV.key?('RAILS_ENV')
          ActiveSupport::Inflector.pluralize(text)
        else
          "#{text}s"
        end
      end

      def camelize(text)
        result = text.split(/[_\s]/)

        return result.first if result.size == 1

        result.map(&:capitalize).join
      end

      def underscore(text)
        return text unless text =~ /[A-Z-]/

        result = text.dup
        result.gsub!(/([A-Z\d]+)([A-Z][a-z])/, '\1_\2')
        result.gsub!(/([a-z\d])([A-Z])/, '\1_\2')
        result.tr!('-', '_')
        result.downcase!
        result
      end
    end
  end
end
