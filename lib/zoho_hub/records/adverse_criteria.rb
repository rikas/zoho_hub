# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class AdverseCriteria < BaseRecord
    request_path 'Adverse_Criteria'

    attributes :id, :account_id, :date_decided, :date_paid
    attributes :status, :amount, :currency, :court
    attributes :case_reference, :entity_details, :data_source

    attribute_translation(
      id: :id,
      case_reference: :Name,
      status: :CCJ_Status,
      amount: :CCJ_Amount,
      data_source: :CCJ_Data_Source,
      date_paid: :Date_paid,
      date_decided: :Date_decided,
      entity_details: :Entity_details
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
