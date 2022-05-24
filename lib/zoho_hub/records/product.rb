# frozen_string_literal: true

module ZohoHub
  class Product < BaseRecord
    attributes :id, :description, :vendor_id, :owner_id, :active, :name

    attribute_translation(
      id: :id,
      active: :Product_Active,
      name: :Product_Name
    )

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr])
      end

      @owner_id ||= params.dig(:Owner, :id)
      @vendor_id ||= params.dig(:Vendor_Name, :id)
    end

    def to_params
      params = super

      params[:Owner] = { id: @owner_id } if @owner_id
      params[:Vendor_Name] = { id: @vendor_id } if @vendor_id

      params
    end
  end
end
