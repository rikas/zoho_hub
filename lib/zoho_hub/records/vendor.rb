# frozen_string_literal: true

module ZohoHub
  class Vendor < BaseRecord
    attributes :id, :email, :description, :vendor_name, :website, :owner_id, :phone, :currency
    attributes :company_reg_no

    attribute_translation(
      id: :id
    )

    DEFAULTS = {
      currency: 'GBP'
    }.freeze

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr] || DEFAULTS[attr])
      end

      @owner_id ||= params.dig(:Owner, :id)
    end

    def to_params
      params = super

      params[:Owner] = { id: @owner_id } if @owner_id

      params
    end
  end
end
