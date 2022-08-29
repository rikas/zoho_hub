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
      get_stub = \
        stub_request(:get, "https://crmsandbox.zoho.eu/crm/v2/Leads/#{test_instance.id}/Notes")
        .to_return(status: 200,
                   body: { data: [{ Note_Title: 'Title', Note_Content: 'content' }] }.to_json)
      notes = test_instance.notes
      expect(notes.class).to eq Array
      expect(notes.first.class).to eq ZohoHub::Note
      expect(notes.first.content).to eq 'content'
      expect(get_stub).to have_been_requested
    end

    context 'without any notes' do
      it 'returns empty array' do
        get_stub = \
          stub_request(:get, "https://crmsandbox.zoho.eu/crm/v2/Leads/#{test_instance.id}/Notes")
          .to_return(status: 200, body: '')
        notes = test_instance.notes
        expect(notes.class).to eq Array
        expect(notes).to be_empty
        expect(get_stub).to have_been_requested
      end
    end
  end
end
