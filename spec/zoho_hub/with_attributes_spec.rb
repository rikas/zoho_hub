# frozen_string_literal: true

RSpec.describe ZohoHub::WithAttributes do
  class TestClass
    include ZohoHub::WithAttributes

    attributes :one, :two, :three
  end

  describe '.attributes' do
    context 'when attributes are passed' do
      it 'adds the attributes to the list of attr_accessors' do
        test = TestClass.new
        test.one = 1
        test.two = 2

        expect(test.one).to eq(1)
        expect(test.two).to eq(2)
      end
    end

    context 'when attributes are not passed' do
      it 'returns the list of attributes' do
        expect(TestClass.attributes).to eq(%i[one two three])
      end
    end
  end

  describe '#attributes' do
    it 'returns the class attributes' do
      test = TestClass.new
      expect(test.attributes).to eq(%i[one two three])
    end
  end
end
