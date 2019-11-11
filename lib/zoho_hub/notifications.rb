# frozen_string_literal: true

require 'zoho_hub/response'
require 'zoho_hub/with_connection'

module ZohoHub
  class Notifications
    include WithConnection

    # Default number of records when fetching all.
    DEFAULT_RECORDS_PER_PAGE = 200

    # Default page number when fetching all.
    DEFAULT_PAGE = 1

    # Minimum number of records to fetch when fetching all.
    MIN_RECORDS = 2

    class << self
      def request_path
        @request_path = 'actions/watch'
      end

      def all(params = {})
        params[:page] ||= DEFAULT_PAGE
        params[:per_page] ||= DEFAULT_RECORDS_PER_PAGE
        params[:per_page] = MIN_RECORDS if params[:per_page] < MIN_RECORDS

        body = get(request_path, params)
        return [] if body.nil?

        response = build_response(body)
        response
      end

      def enable(notify_url, channel_id, events, channel_expiry = nil, token = nil)
        body = post(request_path, watch: [{ notify_url: notify_url,
                                            channel_id: channel_id,
                                            events: events,
                                            channel_expiry: channel_expiry,
                                            token: token }])
        response = build_response(body)

        response
      end

      def build_response(body)
        response = Response.new(body)

        raise RecordInvalid, response.msg if response.invalid_data?
        raise MandatoryNotFound, response.msg if response.mandatory_not_found?

        response.data
      end
    end
  end
end
