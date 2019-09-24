# frozen_string_literal: true

RSpec.describe ZohoHub::WithAttributes do
  let(:test_class) do
    Class.new do
      include ZohoHub::WithAttributes

      attributes :one, :two, :three
    end
  end

  describe '.attributes' do
    context 'when attributes are passed' do
      it 'adds the attributes to the list of attr_accessors' do
        test = test_class.new
        test.one = 1
        test.two = 2

        expect(test.one).to eq(1)
        expect(test.two).to eq(2)
      end
    end

    context 'when attributes are not passed' do
      it 'returns the list of attributes' do
        expect(test_class.attributes).to eq(%i[one two three])
      end
    end
  end

  describe '#attributes' do
    it 'returns the class attributes' do
      test = test_class.new
      expect(test.attributes).to eq(%i[one two three])
    end
  end

  describe '#assign_attributes' do
    context 'when the argument is not a hash' do
      it 'raises an ArgumentError' do
        test = test_class.new
        expect { test.assign_attributes('one: 1, two: 2') }.to raise_exception(ArgumentError)
      end
    end

    it 'assign the object attributes' do
      test = test_class.new
      test.assign_attributes(one: 1, two: 2)
      expect(test.one).to eq(1)
      expect(test.two).to eq(2)
      expect(test.three).to eq(nil)
    end
  end
end
