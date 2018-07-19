# frozen_string_literal: true

module ZohoHub
  class Response
    def initialize(params)
      @params = params || {}
    end

    def invalid_data?
      data[:code] == 'INVALID_DATA'
    end

    # {:code=>"INVALID_TOKEN", :details=>{}, :message=>"invalid oauth token", :status=>"error"}
    def invalid_token?
      data[:code] == 'INVALID_TOKEN'
    end

    def empty?
      @params.empty?
    end

    def data
      data = @params[:data] if @params.dig(:data)
      data ||= @params

      return data.first if data.is_a?(Array) && data.size == 1

      data
    end

    def msg
      msg = data[:message]

      if data.dig(:details, :expected_data_type)
        expected = data.dig(:details, :expected_data_type)
        field = data.dig(:details, :api_name)

        msg << ", expected #{expected} for '#{field}'"
      end

      msg
    end
  end
end
