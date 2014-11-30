require "rails_helper"

describe "Session API" do

  def post_session(election_uri, access_token:)
    post "session", election: election_uri, accessToken: access_token
  end

  it_behaves_like "api that validates election URI", agent: :booth, state: :open do
    let(:apicall) { -> election_uri { post_session election_uri, access_token: "anything" } }
  end

  describe "with valid election URI" do
    let(:election_uri) { stub_election_uri(booth: my_agent_uri) }
    let(:valid_access_token) { stub_election_access_token(election_uri: election_uri) }
    let(:invalid_access_token) { stub_election_access_token(election_uri: election_uri, valid: false) }

    it "accepts valid access token" do
      post_session election_uri, access_token: valid_access_token
      expect(response).to have_http_status 200
      expect(response_json).to match_json_schema(:session_schema)
    end

    it "rejects invalid access token" do
      post_session election_uri, access_token: invalid_access_token
      expect(response).to have_http_status 403
      expect(response_json["error"]).to match /token/i
    end

  end

end
