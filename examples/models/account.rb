# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  class Account < BaseRecord
    attributes :id, :name, :territories, :company_number, :employee_count, :company_type, :industry
    attributes :billing_city, :billing_code, :billing_country, :billing_street, :billing_state
    attributes :account_type

    # This is the ID to be used when the borrower has no organisation (unlikely) or belongs to
    # multiple organisations.
    CATCH_ALL_ID = '78265000000826001'

    DEFAULTS = {
      account_type: 'Prospect'
    }.freeze

    # The translation from attribute name to the JSON field on Zoho. The default behaviour will be
    # to Camel_Case the attribute so on this list we should only have exceptions to this rule.
    attribute_translation(
      id: :id,
      name: :Account_Name,
      company_number: :company_reg_id,
      employee_count: :No_of_Employees,
      industry: :Industry_Category
    )

    def initialize(params)
      attributes.each do |attr|
        zoho_key = attr_to_zoho_key(attr)

        send("#{attr}=", params[zoho_key] || params[attr] || DEFAULTS[attr])
      end
    end

    def to_params
      params = super

      params
    end
  end
end
