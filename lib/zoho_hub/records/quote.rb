# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Quote < BaseRecord
    attributes :id, :stage, :subject
    attributes :potential_id

    attribute_translation(
      id: :id,
      stage: :Quote_Stage
    )

    def initialize(params)
      puts Rainbow(params).bright.red
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr])
      end

      @potential_id ||= params.dig(:Deal_Name, :id)
      @lender_organisation_id ||= params.dig(:Account_Name, :id)
    end

    def to_params
      params = super

      params[:Deal_Name] = { id: @potential_id } if @potential_id
      params[:Account_Name] = { id: @lender_organisation_id } if @lender_organisation_id
    end
  end
end
