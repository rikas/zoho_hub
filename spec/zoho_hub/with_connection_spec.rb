# frozen_string_literal: true

RSpec.describe ZohoHub::WithConnection do
  class TestClass
    include ZohoHub::WithConnection
  end

  describe '.get' do
    it 'fires a get request with ZohoHub::Connection' do
      VCR.use_cassette('modules_get') do
        TestClass.get('/settings/modules')
      end
    end
  end
end
