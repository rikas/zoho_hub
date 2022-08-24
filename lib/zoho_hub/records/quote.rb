# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Quote < BaseRecord
    attributes :id, :stage, :subject, :potential_id, :owner_id, :product_id, :account_id, :extra_info
    attributes :funding_amount, :financed_on

    attribute_translation(
      id: :id,
      stage: :Quote_Stage,
      financed_on: :Financed_on
    )

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)
        send("#{attr}=", params[zoho_key] || params[attr])
      end

      @potential_id ||= params.dig(:Deal_Name, :id)
      @account_id ||= params.dig(:Account_Name, :id)
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
      params[:Account_Name] = { id: @account_id } if @account_id
      params[:Owner] = { id: @owner_id } if @owner_id
      params[:Product_Details] = [{ product: { id: @product_id }, quantity: 1 }] if @product_id

      params
    end
  end
end
