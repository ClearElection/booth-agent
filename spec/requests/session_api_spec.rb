require "rails_helper"

describe "Session API" do

  it_behaves_like "api validates election URI", agent: :booth, state: :open do
    let(:apicall) { -> election_uri { post "/session", election: election_uri, accessToken: "anything" } }
  end

  describe "with valid election URI" do
    Given(:election_uri) { stub_election_uri(booth: my_agent_uri) }
    Given(:validAccessToken) { stub_election_access_token(election_uri: election_uri) }
    Given(:invalidAccessToken) { stub_election_access_token(election_uri: election_uri, valid: false) }

    When { post "/session", election: election_uri, accessToken: accessToken }

    describe "with valid access token" do
      Given(:accessToken) { validAccessToken }
      Then { expect(response).to have_http_status 200 }
      Then { expect(response_json).to match_json_schema(:session_schema) }
    end

    describe "with invalid access token" do
      Given(:accessToken) { invalidAccessToken }
      Then { expect(response).to have_http_status 403 }
      Then { expect(response_json["error"]).to match /token/i }
    end

  end


end
