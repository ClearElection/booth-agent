require "rails_helper"

describe "Returns API" do
  Given(:validElection) { ClearElection::Factory.election(booth: my_agent_uri, pollsClose: 1.day.ago) }
  Given(:validElectionUri) { stub_election_uri(election: validElection) }

  Given(:otherAgentElectionUri) { stub_election_uri() }
  Given(:invalidElectionUri) { stub_election_uri(valid: false) }

  When { get "/returns", election: election_uri }

  describe "with valid election" do
    Given(:election_uri) { validElectionUri }

    describe "with data" do
      Given(:nsessions) { 3 }
      Given(:ncast) { 2 }
      Given(:ballots) { [] }
      Given {
        nsessions.times do |i|
          session = FactoryGirl.create(:session, election_uri: election_uri)
          if i < ncast
            ballot = filled_ballot(session)
            session.ballot_record.cast_ballot(ballot.as_json)
            ballots << ballot
          end
        end
      }

      Then { expect(response).to have_http_status 200 }
      Then { expect(response_json["ballotsIssued"]).to eq nsessions }
      Then { expect(response_json["ballotsCast"]).to eq ncast }
      Then { expect(response_json["ballots"]).to eq ballots.sort.map(&:as_json) }
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
