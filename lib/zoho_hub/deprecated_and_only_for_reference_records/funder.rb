# frozen_string_literal: true

module ZohoHub
  class Vendor < BaseRecord
    def initialize(params)
      puts Rainbow(params).red.bright
    end
  end
end
