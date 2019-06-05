# frozen_string_literal: true

require 'zoho_hub/records/base_record'

module ZohoHub
  # Simple manual Zoho record where we just want to get the name. Something like:
  # #<ZohoHub::Campaign:0x00007fce2cc22458 @id="78265000003433063", @name="Smith & Williamson">
  class Campaign < BaseRecord
    attributes :id, :name

    attribute_translation name: :Campaign_Name
  end
end
