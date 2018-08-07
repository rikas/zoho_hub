# frozen_string_literal: true

module ZohoHub
  class Product < BaseRecord
    def initialize(params)
      puts Rainbow(params).red.bright
    end
  end
end
