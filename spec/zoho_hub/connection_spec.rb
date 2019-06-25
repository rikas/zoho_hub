# frozen_string_literal: true

require 'pry'
require 'zoho_hub/connection'

RSpec.describe ZohoHub::Connection do
  context 'when initializing a new Connection' do
    describe '@api_domain' do
      it 'should correspond to config api_domain - US' do
        ZohoHub.configuration.api_domain = 'https://accounts.zoho.com'
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq('https://www.zohoapis.com')
      end

      it 'should correspond to config api_domain - CN' do
        ZohoHub.configuration.api_domain = 'https://accounts.zoho.com.cn'
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq('https://www.zohoapis.com.cn')
      end

      it 'should correspond to config api_domain - IN' do
        ZohoHub.configuration.api_domain = 'https://accounts.zoho.in'
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq('https://www.zohoapis.in')
      end

      it 'should correspond to config api_domain - EU' do
        ZohoHub.configuration.api_domain = 'https://accounts.zoho.eu'
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq('https://www.zohoapis.eu')
      end

      it 'should default if config api_domain is nil' do
        ZohoHub.configuration.api_domain = nil
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq(described_class::DEFAULT_DOMAIN)
      end

      it 'should default if config api_domain is empty' do
        ZohoHub.configuration.api_domain = ''
        result = described_class.new(access_token: '').api_domain

        expect(result).to eq(described_class::DEFAULT_DOMAIN)
      end

      it 'should allow overriding via argument' do
        ZohoHub.configuration.api_domain = 'https://accounts.zoho.eu'
        connection = described_class.new(access_token: '',
                                         api_domain: 'custom domain')
        result = connection.api_domain

        expect(result).to eq('custom domain')
      end
    end
  end
end
