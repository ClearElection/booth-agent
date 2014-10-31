require "rails_helper"

describe "Returns API" do
  Given(:validElection) { ClearElection::Factory.election(booth: my_agent_uri) }
  Given(:validElectionUri) { stub_election_uri(election: validElection) }

  Given(:otherAgentElectionUri) { stub_election_uri() }
  Given(:invalidElectionUri) { stub_election_uri(valid: false) }

  When { get "/returns", election: election_uri }

  describe "with valid election" do
    Given(:election_uri) { validElectionUri }

    describe "if polls are closed" do
      Given{ Timecop.travel(validElection.pollsClose + 1.day) }
      Then { expect(response).to have_http_status 200 }
    end

    describe "if polls are not closed" do
      Given{ Timecop.travel(validElection.pollsClose - 1.day) }
      Then { expect(response).to have_http_status 403 }
      Then { expect(response_error_message).to match /closed/i }
    end

  end

  describe "with invalid election" do

    describe "other booth agent" do
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
