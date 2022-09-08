# frozen_string_literal: true

RSpec.describe ZohoHub::WithConnection do
  let(:test_class) do
    Class.new do
      include ZohoHub::WithConnection
    end
  end

  describe '.get' do
    it 'fires a get request with ZohoHub::Connection' do
      get_stub = stub_request(:get, 'https://crmsandbox.zoho.eu/settings/modules')
                 .to_return(status: 200, body: '', headers: {})

      test_class.get('/settings/modules')

      expect(get_stub).to have_been_requested.once
    end
  end
end
