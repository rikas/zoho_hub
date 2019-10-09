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

  describe '.pluralize' do
    it 'returns the given text with an ending "s"' do
      result = described_class.pluralize('test')

      expect(result).to eq('tests')
    end

    context 'when Rails is available' do
      it 'uses ActiveSupport::Inflector' do
        require 'active_support/inflector'

        result = described_class.pluralize('octopus')

        expect(result).to eq('octopi')
      end
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
    it 'returns the same string if the given text has no words or dashes' do
      text = '1238|#$%&@!;'

      result = described_class.underscore(text)

      expect(result).to eq(text)
    end

    it 'replaces dashes with underscores' do
      text = 'hello-world-this-is-a-test'

      result = described_class.underscore(text)

      expect(result).to eq('hello_world_this_is_a_test')
    end

    it 'returns a lowercased string with underscores when case changes' do
      text = 'HelloWORLD'

      result = described_class.underscore(text)

      expect(result).to eq('hello_world')
    end
  end
end
