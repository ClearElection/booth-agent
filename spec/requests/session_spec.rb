require "rails_helper"

describe "Session API" do

  Given(:accessToken) { "TestAccessToken" }

  When { post "/session", election: election_uri, accessToken: accessToken }

  describe "with valid election" do

    Given(:polls_open) { DateTime.now - 1.year }
    Given(:polls_close) { DateTime.now + 1.year }
    Given(:election) { ClearElection::Factory.election(booth: election_booth_uri, pollsOpen: polls_open, pollsClose: polls_close) }
    Given(:election_uri) { stub_election_uri(election: election) }

    describe "with this booth agent" do
      Given(:election_booth_uri) { my_agent_uri }

      describe "if polls are open" do

        describe "with valid access token" do
          Given { stub_request(:post, election.signin.uri + "redeem") }

          Then { expect(response).to have_http_status 200 }
          Then { expect(response_json).to match_json_schema(:session_schema) }
        end

        describe "with invalid access token" do
          Given { stub_request(:post, election.signin.uri + "redeem").to_return status: 403 }
          Then { expect(response).to have_http_status 403 }
          Then { expect(response_json["error"]).to match /token/i }
        end
      end

      describe "if polls haven't opened yet" do
        Given(:polls_open) { DateTime.now + 1.day }
        Then { expect(response).to have_http_status 403 }
        Then { expect(response_json["error"]).to match /open/i }
      end

      describe "if polls are closed" do
        Given(:polls_close) { DateTime.now - 1.day }
        Then { expect(response).to have_http_status 403 }
        Then { expect(response_json["error"]).to match /open/i }
      end

    end

    describe "with other booth agent" do
      Given(:election_booth_uri) { ClearElection::Factory.agent_uri("booth") }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_json["error"]).to match /booth agent/i }
    end
  end

  describe "with invalid election" do
    Given(:election_uri) { ClearElection::Factory.election_uri }
    Given { stub_request(:get, election_uri).to_return status: 404 }
    Then { expect(response).to have_http_status 422 }
    Then { expect(response_json["error"]).to match /uri/i }
  end

end
