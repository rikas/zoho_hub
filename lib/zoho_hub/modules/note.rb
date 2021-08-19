# frozen_string_literal: true

module ZohoHub
  class BaseRecord
    class << self
      def add_note(id:, title: '', content: '')
        path = File.join(request_path, id, 'Notes')
        post(path, data: [{ Note_Title: title, Note_Content: content }])
      end
    end

    def notes
      path = File.join(self.class.request_path, id, 'Notes')
      body = get(path)
      response = build_response(body)
      response.data.map do |data_note|
        ZohoHub::Note.new(data_note)
      end || []
    end
  end

  class Note < BaseRecord
    attributes :id, :created_by, :modified_by, :owner, :parent_id, :created_time, :voice_note,
               :note_title, :note_content

    attribute_translation id: :id
    alias title note_title
    alias content note_content
  end
end
