# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Quote < BaseRecord
    attributes :id, :stage, :subject, :potential_id, :owner_id, :product_id

    attribute_translation(
      id: :id,
      stage: :Quote_Stage
    )

    def initialize(params)
      puts Rainbow(params).bright.red
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)
        puts "Sending #{attr}=, zoho_key: #{zoho_key}"
        send("#{attr}=", params[zoho_key] || params[attr])
      end

      @potential_id ||= params.dig(:Deal_Name, :id)
      @lender_organisation_id ||= params.dig(:Account_Name, :id)
      @owner_id ||= params.dig(:Owner, :id)

      # The Quote has an array of products but we only care about one
      if params.dig(:Product_Details)
        product = params.dig(:Product_Details).first
        @product_id = product.dig(:id)
      end
    end

    def to_params
      params = super

      params[:Deal_Name] = { id: @potential_id } if @potential_id
      params[:Account_Name] = { id: @lender_organisation_id } if @lender_organisation_id
      params[:Owner] = { id: @owner_id } if @owner_id
      params[:Product_Details] = [{ id: @product_id }] if @product_id
    end
  end
end
