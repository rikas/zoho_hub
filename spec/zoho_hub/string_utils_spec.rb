# frozen_string_literal: true

require 'zoho_hub/string_utils'

RSpec.describe ZohoHub::StringUtils do
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

  describe '.camelize' do
    it 'returns a CamelCase word instead of snake_case' do
      result = described_class.camelize('snake_case_word')

      expect(result).to eq('SnakeCaseWord')
    end

    it 'returns a CamelCase word for multiple word string' do
      result = described_class.camelize('snake case word')

      expect(result).to eq('SnakeCaseWord')
    end

    it 'keeps the original word if needed' do
      result = described_class.camelize('OriginalWordIsOk')

      expect(result).to eq('OriginalWordIsOk')
    end

    it 'works with words already capitalized' do
      result = described_class.camelize('This_is The ULTIMATE_test')

      expect(result).to eq('ThisIsTheUltimateTest')
    end
  end

  describe '.underscore' do
  end
end
