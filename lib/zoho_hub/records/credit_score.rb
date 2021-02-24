# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class CreditScore < BaseRecord
    request_path 'Credit_Scores'

    attributes :id, :account_id, :credit_data_source, :credit_score_band
    attributes :score_description, :credit_score_number, :credit_limit, :currency

    attribute_translation(
      id: :id,
      credit_score_number: :Name
    )

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr])
      end

      # Setup values as they come from the Zoho API if needed
      @account_id ||= params.dig(:Account_Name, :id)
    end

    def to_params
      params = super

      params[:Account_Name] = { id: @account_id } if @account_id

      params
    end
  end
end
