# frozen_string_literal: true

RSpec.describe ZohoHub::StringTools do
  describe '.demodulize' do
    it 'returns the class name without the modules' do
      result = described_class.demodulize('ZohoHub::Settings::Configuration')

      expect(result).to eq('Configuration')
    end

    it 'returns the class name if it only has one level of modulization' do
      result = described_class.demodulize('Facebook::User')

      expect(result).to eq('User')
    end

    it 'returns the class name if there are no modules' do
      result = described_class.demodulize('String')

      expect(result).to eq('String')
    end
  end
end
