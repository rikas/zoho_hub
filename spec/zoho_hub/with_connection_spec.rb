# frozen_string_literal: true

RSpec.describe ZohoHub::WithConnection do
  let(:test_class) do
    Class.new do
      include ZohoHub::WithConnection
    end
  end

  describe '.get' do
    it 'fires a get request with ZohoHub::Connection' do
      VCR.use_cassette('modules_get') do
        test_class.get('/settings/modules')
      end
    end
  end
end
