# frozen_string_literal: true

RSpec.describe ZohoHub::BaseRecord do
  let(:test_class) do
    Class.new(described_class) do
      attributes :my_string, :my_bool
    end
  end

  describe '#build_response' do
    context 'with an empty string and a "false" boolean' do
      let(:body) { { data: [{ My_String: '', My_Bool: false }] } }

      it 'correctly construct the record' do
        response = test_class.build_response(body)
        record = test_class.new(response.data.first)

        expect(record.my_string).to eq('')
        expect(record.my_bool).to eq(false)
      end
    end
  end

  describe '#notes' do
    let(:test_instance) do
      described_class.new
    end

    before do
      allow(described_class).to receive(:to_s).and_return('Lead')
      allow(test_instance).to receive(:id).and_return('123456789')
    end

    it 'fetchs notes from the record' do
      VCR.use_cassette('notes_get') do
        notes = test_instance.notes
        expect(notes.class).to eq Array
        expect(notes.first.class).to eq ZohoHub::Note
        expect(notes.first.content).to eq 'en attente des docs'
      end
    end

    context 'without any notes' do
      it 'returns empty array' do
        VCR.use_cassette('notes_get_none') do
          notes = test_instance.notes
          expect(notes.class).to eq Array
          expect(notes).to be_empty
        end
      end
    end
  end
end
