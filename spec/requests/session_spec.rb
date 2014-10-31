require "rails_helper"

describe "Session API" do
  Given(:validElection) { ClearElection::Factory.election(booth: my_agent_uri) }
  Given(:validElectionUri) { stub_election_uri(election: validElection) }
  Given(:otherAgentElectionUri) { stub_election_uri() }
  Given(:invalidElectionUri) { stub_election_uri(valid: false) }

  Given(:validAccessToken) { stub_access_token(election_uri: validElectionUri) }
  Given(:invalidAccessToken) { stub_access_token(election_uri: validElectionUri, valid: false) }

  When { post "/session", election: election_uri, accessToken: accessToken }

  describe "with valid election" do
    Given(:election_uri) { validElectionUri }

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

    describe "if polls haven't opened yet" do
      Given(:accessToken) { "anything" }
      Given{ Timecop.travel(validElection.pollsOpen - 1.day) }
      Then { expect(response).to have_http_status 403 }
      Then { expect(response_json["error"]).to match /open/i }
    end

    describe "if polls are closed" do
      Given(:accessToken) { "anything" }
      Given{ Timecop.travel(validElection.pollsClose + 1.day) }
      Then { expect(response).to have_http_status 403 }
      Then { expect(response_json["error"]).to match /open/i }
    end

  end

  describe "with invalid election" do
    Given(:accessToken) { "anything" }

    describe "with other booth agent" do
      Given(:election_uri) { otherAgentElectionUri }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_json["error"]).to match /booth agent/i }
    end

    describe "invalid uri" do
      Given(:election_uri) { invalidElectionUri }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_json["error"]).to match /uri/i }
    end
  end

end
