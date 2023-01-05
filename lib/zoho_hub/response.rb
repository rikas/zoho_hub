# frozen_string_literal: true

module ZohoHub
  class Response
    def initialize(params)
      @params = params || {}
    end

    def empty?
      @params.empty?
    end

    def data
      data = @params[:data] if @params[:data]
      data || @params
    end

    def msg
      first_data = data.is_a?(Array) ? data.first : data
      msg = first_data[:message]

      if first_data.dig(:details, :expected_data_type)
        expected = first_data.dig(:details, :expected_data_type)
        field = first_data.dig(:details, :api_name)
        parent_api_name = first_data.dig(:details, :parent_api_name)

        msg << ", expected #{expected} for '#{field}'"
        msg << " in #{parent_api_name}" if parent_api_name
      end

      msg
    end

    # Error response examples:
    # {"data":[{"code":"INVALID_DATA","details":{},"message":"the id given...","status":"error"}]}
    # {:code=>"INVALID_TOKEN", :details=>{}, :message=>"invalid oauth token", :status=>"error"}
    def error?
      if data.is_a?(Array)
        return false if data.size > 1
        return data.first[:status] == 'error'
      end

      data[:status] == 'error'
    end

    def error_code
      if data.is_a?(Array)
        return if data.size > 1
        return data.first[:code]
      end

      data[:code]
    end

    def error_class
      ERROR_CLASSES_MAPPING.fetch(error_code, UnknownError)
    end

    def authentication_error?
      error? && %w[INVALID_TOKEN AUTHENTICATION_FAILURE].include?(error_code)
    end
  end
end
