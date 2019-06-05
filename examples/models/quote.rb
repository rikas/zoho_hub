# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Quote < BaseRecord
    attributes :id, :stage, :subject, :potential_id

    # The translation from attribute name to the JSON field on Zoho. The default behaviour will be
    # to Camel_Case the attribute so on this list we should only have exceptions to this rule.
    attribute_translation(
      id: :id,
      stage: :Quote_Stage
    )

    def initialize(params = {})
      super

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
