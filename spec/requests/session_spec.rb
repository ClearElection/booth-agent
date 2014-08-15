require "rails_helper"

describe "Session API" do

  Given!(:booth_host) { "dummy-booth.com".tap {|host| host! host } }

  Given(:election_uri) { "http://dummy-election.org/electionID" }
  Given(:election) { ClearElection::Factory.election(booth: booth_uri) }
  Given(:accessToken) { "TestAccessToken" }

  When { post "/sessions", election: election_uri, accessToken: accessToken }

  describe "with valid election" do
    Given { stub_request(:get, election_uri).to_return body: -> request { election.as_json } }

    describe "with this booth agent" do
      Given(:booth_uri) { "http://#{booth_host}" }

      describe "with valid access token" do
        Given { stub_request(:post, election.registrar.uri + "redeem") }

        Then { expect(response).to have_http_status 200 }
        Then { expect(response_json).to match_json_schema(:session_schema) }
        Then { expect(response_json["ballot"].map(&it["contestId"])).to match_array election.contests.map(&:contestId) }
      end

      describe "with invalid access token" do
        Given { stub_request(:post, election.registrar.uri + "redeem").to_return status: 403 }
        Then { expect(response).to have_http_status 403 }
      end

    end

    describe "with other booth agent" do
      Given(:booth_uri) { "http://other.booth-agent.com" }
      Then { expect(response).to have_http_status 422 }
    end

  end

  describe "with invalid election" do
    Given { stub_request(:get, election_uri).to_return status: 404 }
    Then { expect(response).to have_http_status 422 }
  end

end
