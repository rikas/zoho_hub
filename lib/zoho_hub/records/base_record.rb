# frozen_string_literal: true

require 'zoho_hub/response'

module ZohoHub
  class BaseRecord
    class << self
      def record_name(name = nil)
        @record_name = name if name
        @record_name ||= to_s.demodulize.pluralize
        @record_name
      end

      def list_name(name = nil)
        @list_name = name if name
        @list_name ||= to_s.demodulize.pluralize.downcase
        @list_name
      end

      def attributes(*attributes)
        @attributes ||= []

        return @attributes unless attributes

        attr_accessor(*attributes)

        @attributes += attributes
      end

      def attribute_translation(translation = nil)
        @attribute_translation ||= {}

        return @attribute_translation unless translation

        @attribute_translation = translation
      end

      def zoho_key_translation
        @attribute_translation.to_a.map(&:rotate).to_h
      end

      def find(id)
        body = get(File.join(record_name, id.to_s))
        response = build_response(body)

        if response.empty?
          raise RecordNotFound, "Couldn't find #{record_name.singularize} with 'id'=#{id}"
        end

        new(response.data)
      end

      def where(params)
        response = get(list_name, params)
        data = response[:data]

        data.map { |info| new(info) }
      end

      def find_by(params)
        records = where(params)
        records.first
      end

      def create(params)
        new(params).save
      end

      def all(options = {})
        options[:page] ||= 1
        options[:per_page] ||= 200

        body = get(list_name, options)
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |info| new(info) }
      end

      def get(path, params = {})
        ZohoHub.connection.get(path, params)
      end

      def post(path, params = {})
        ZohoHub.connection.post(path, params.to_json)
      end

      def put(path, params = {})
        ZohoHub.connection.put(path, params.to_json)
      end

      def exists?(id)
        !find(id).nil?
      rescue RecordNotFound
        false
      end

      alias exist? exists?

      def build_response(body)
        response = Response.new(body)

        raise InvalidTokenError, response.msg if response.invalid_token?
        raise RecordInvalid, response.msg if response.invalid_data?

        response
      end
    end

    def attributes
      self.class.attributes
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

    def save
      body = if new_record?
               post(self.class.record_name, data: [to_params])
             else
               path = URI.join(self.class.record_name, zoho_id)
               put(path, data: [to_params])
             end

      response = build_response(body)

      response.data.dig(:details, :id)
    end

    def new_record?
      !zoho_id.present?
    end

    def to_params
      params = {}

      attributes.each do |attr|
        key = attr_to_zoho_key(attr)

        params[key] = send(attr)
      end

      params
    end

    def build_response(body)
      self.class.build_response(body)
    end

    private

    def attr_to_zoho_key(attr_name)
      translations = self.class.attribute_translation

      return translations[attr_name.to_sym] if translations.key?(attr_name.to_sym)

      attr_name.to_s.split('_').map(&:capitalize).join('_').to_sym
    end

    def zoho_key_to_attr(zoho_key)
      translations = self.class.zoho_key_translation

      return translations[zoho_key.to_sym] if translations.key?(zoho_key.to_sym)

      zoho_key.to_sym
    end
  end
end
