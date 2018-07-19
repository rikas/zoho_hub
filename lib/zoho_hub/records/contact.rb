# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Contact < BaseRecord
    attributes :id, :email, :salutation, :first_name, :mobile, :role, :last_name
    attributes :account_id, :owner_id, :campaign_id, :status, :campaign_detail

    attribute_translation(
      id: :id,
      role: :platform_cont_type,
      status: :platform_cont_status,
      use_proceeds: :use_proceeds
    )

    DEFAULTS = {
      status: 'active',
      campaign_detail: 'Web Sign Up'
    }.freeze

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr] || DEFAULTS[attr])
      end

      # Setup values as they come from the Zoho API if needed
      @account_id ||= params.dig(:Account_Name, :id)
      @owner_id ||= params.dig(:Owner, :id)
      @campaign_id ||= params.dig(:Campaign_Lookup, :id)
    end

    def to_params
      params = super

      params[:Account_Name] = { id: @account_id } if @account_id
      params[:Owner] = { id: @owner_id } if @owner_id
      params[:Campaign_Lookup] = { id: @campaign_id } if @campaign_id

      params
    end
  end
end
