# frozen_string_literal: true

require 'zoho_hub/base_record'

module ZohoHub
  class BaseRecord
    class << self
      def related_attachments(parent_id:)
        body = get(File.join(request_path, parent_id, 'Attachments'))
        response = build_response(body)

        data = response.nil? ? [] : response.data

        data.map { |json| Attachment.new(json) }
      end

      def download_attachment(parent_id:, attachment_id:)
        attachment = related_attachments(parent_id: parent_id).find { |a| a.id == attachment_id }
        uri = File.join(request_path, parent_id, 'Attachments', attachment_id)
        res = ZohoHub.connection.adapter.get(uri)
        attachment.content_type = res.headers['content-type']
        extension = File.extname(attachment.file_name)
        basename = File.basename(attachment.file_name, extension)
        file = Tempfile.new([basename, extension])
        file.binmode
        file.write(res.body)
        file.rewind
        attachment.file = file
        attachment
      end
    end
  end

  class Attachment < BaseRecord
    attributes :id, :file_name, :created_by, :modified_by, :owner, :parent_id, :created_time,
               :modified_time, :size

    attribute_translation id: :id
    attr_accessor :content_type, :file
  end
end
