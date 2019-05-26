# frozen_string_literal: true

module ZohoHub
  # Adds the ability to do API requests (GET / PUT and POST requests) when included in a class.
  module WithConnection
    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def get(path, params = {})
        ZohoHub.connection.get(path, params)
      end

      def post(path, params = {})
        ZohoHub.connection.post(path, params.to_json)
      end

      def put(path, params = {})
        ZohoHub.connection.put(path, params.to_json)
      end

      def delete(path, params = {})
        ZohoHub.connection.delete(path, params.to_json)
      end
    end

    def get(path, params = {})
      self.class.get(path, params)
    end

    def post(path, params = {})
      self.class.post(path, params)
    end

    def put(path, params = {})
      self.class.put(path, params)
    end

    def delete(path, params = {})
      self.class.delete(path, params)
    end
  end
end
