# frozen_string_literal: true

module ZohoHub
  class Response
    def initialize(params)
      @params = params || {}
    end

    def invalid_data?
      return false if data.is_a?(Array)

      data[:code] == 'INVALID_DATA'
    end

    # {:code=>"INVALID_TOKEN", :details=>{}, :message=>"invalid oauth token", :status=>"error"}
    def invalid_token?
      return false if data.is_a?(Array)

      data[:code] == 'INVALID_TOKEN'
    end

    def authentication_failure?
      return false if data.is_a?(Array)

      data[:code] == 'AUTHENTICATION_FAILURE'
    end

    def empty?
      @params.empty?
    end

    def data
      data = @params[:data] if @params.dig(:data)
      data || @params
    end

    def msg
      msg = data[:message]

      if data.dig(:details, :expected_data_type)
        expected = data.dig(:details, :expected_data_type)
        field = data.dig(:details, :api_name)
        parent_api_name = data.dig(:details, :parent_api_name)

        msg << ", expected #{expected} for '#{field}'"
        msg << " in #{parent_api_name}" if parent_api_name
      end

      msg
    end
  end
end
