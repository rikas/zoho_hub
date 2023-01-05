# frozen_string_literal: true
FactoryBot.define do
  sequence :zoho_id do |n|
    "2000000#{n.to_s.rjust(12, '0')}"
  end
end
