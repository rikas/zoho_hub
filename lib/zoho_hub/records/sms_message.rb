# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class SMSMessage < BaseRecord
    attributes :id, :template, :state, :text, :contact_id, :potential_id, :name, :sent_by

    attribute_translation id: :id

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr])
      end

      # Setup values as they come from the Zoho API if needed
      @contact_id ||= params.dig(:Contact, :id)
      @potential_id ||= params.dig(:Potential, :id)
    end

    def to_params
      params = super

      params[:Contact] = { id: @contact_id } if @contact_id
      params[:Potential] = { id: @potential_id } if @potential_id

      params
    end
  end
end
