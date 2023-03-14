# frozen_string_literal: true

require 'zoho_hub/records/base_record'
require 'faraday/multipart'

module ZohoHub
  class Attachment < BaseRecord
    attributes :id, :parent_id, :file_name, :link_url, :type, :created_time
    attributes :parent, :attachment_url

    # The translation from attribute name to the JSON field on Zoho. The default behaviour will be
    # to Camel_Case the attribute so on this list we should only have exceptions to this rule.
    attribute_translation(
      id: :id,
      link_url: :'$link_url',
      type: :'$type'
    )

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr])
      end

      @parent_id = params.dig(:Parent_Id, :id)
    end

    class << self
      def exists?(id, parent:)
        !find(id, parent: parent).nil?
      rescue RecordNotFound
        false
      end

      def find(id, parent:)
        body = get(File.join(request_path, id.to_s), parent: parent)
        response = build_response(body)

        if response.empty?
          raise RecordNotFound, "Couldn't find #{request_path.singularize} with 'id'=#{id}"
        end

        new(response.data)
      end

      def get(path, parent:, **params)
        # remove /search added by where method
        path = path.sub('/search', '')
        ZohoHub.connection.get(parent_module_path(path, parent), params)
      end

      def post(path, parent:, **params)
        ZohoHub.connection.post(parent_module_path(path, parent), params) do |conn|
          conn.request :multipart
          conn.request :url_encoded
        end
      end

      def put(_path, _params = {})
        raise NotImplementedError
      end

      def parent_module_path(path, parent)
        File.join(
          parent.class.request_path,
          parent.id,
          path
        )
      end
    end

    def post(path, _params = {})
      self.class.post(path, parent: parent, **to_params)
    end

    def put(_path, _params = {})
      raise NotImplementedError
    end

    def save(*)
      super
    rescue => e
      if e.message.include?('Attachment link already exists')
        raise AttachmentLinkTakenError, e.message
      else
        raise e
      end
    end

    def to_params
      { attachmentUrl: attachment_url }
    end

    private

    def to_input(**)
      to_params
    end

    def parent_module_path(path)
      self.class.parent_module_path(path, parent)
    end
  end
end
