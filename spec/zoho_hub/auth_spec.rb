# frozen_string_literal: true

RSpec.describe ZohoHub::Auth do
  describe '.refresh_token' do
    let(:refresh_token) { 'xxx'}
    let(:access_token) { 'aaa'}

    let!(:token_refresh_stub) do
      stub_request(:post, "#{ZohoHub.configuration.api_domain}/oauth/v2/token?client_id&client_secret"\
                          "&grant_type=refresh_token&refresh_token=xxx"
      ).and_return(body: { access_token: access_token }.to_json)
    end

    it "returns a refreshed token" do
      token = described_class.refresh_token(refresh_token)
      expect(token).to eq({ refresh_token: refresh_token, access_token: access_token })
      expect(token_refresh_stub).to have_been_requested
    end
  end
end
