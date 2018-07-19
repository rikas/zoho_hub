# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Campaign < BaseRecord
    attributes :id, :name

    def initialize(params)
      @id = params[:id]
      @name = params[:Campaign_Name]
    end
  end
end
