# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  # The Campaign class represents a Finpoint partner program (PartnerProgram model).
  class Campaign < BaseRecord
    attributes :id, :name

    def initialize(params)
      @id = params[:id]
      @name = params[:Campaign_Name]
    end
  end
end
