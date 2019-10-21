# frozen_string_literal: true

RSpec.describe ZohoHub::BaseRecord do
  let(:test_class) do
    Class.new(described_class) do
      attributes :my_string, :my_bool
    end
  end

  describe '#build_response' do
    context 'with an empty string and a "false" boolean' do
      # rubocop:disable Style/HashSyntax
      let(:body) { { :data => [{ :My_String => '', :My_Bool => false }] } }
      # rubocop:enable Style/HashSyntax

      it 'correctly construct the record' do
        response = test_class.build_response(body)
        record = test_class.new(response.data.first)

        expect(record.my_string).to eq('')
        expect(record.my_bool).to eq(false)
      end
    end
  end
end
