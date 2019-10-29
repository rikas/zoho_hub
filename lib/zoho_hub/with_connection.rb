# frozen_string_literal: true

module ZohoHub
  # Adds the ability to do API requests (GET / PUT and POST requests) when included in a class.
  module WithConnection
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def get(path, params = {}, &block)
        ZohoHub.connection.get(path, params, &block)
      end

      def post(path, params = {}, &block)
        ZohoHub.connection.post(path, params.to_json, &block)
      end

      def put(path, params = {}, &block)
        ZohoHub.connection.put(path, params.to_json, &block)
      end

      def delete(path, params = {}, &block)
        ZohoHub.connection.delete(path, params, &block)
      end
    end

    def get(path, params = {}, &block)
      self.class.get(path, params, &block)
    end

    def post(path, params = {}, &block)
      self.class.post(path, params, &block)
    end

    def put(path, params = {}, &block)
      self.class.put(path, params, &block)
    end

    def delete(path, params = {}, &block)
      self.class.delete(path, params, &block)
    end
  end
end
