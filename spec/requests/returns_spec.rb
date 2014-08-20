require "rails_helper"

describe "Returns API" do

  Given(:election) { ClearElection::Factory.election(booth: my_uri) }
  Given(:election_uri) { stub_election_uri(election) }

  Given(:nsessions) { 3 }
  Given(:ncast) { 2 }
  Given(:ballots) { [] }

  Given {
    nsessions.times do |i|
      session = FactoryGirl.create(:session, election_uri: election_uri)
      if i < ncast
        ballot = get_ballot(session)
        session.ballot_record.cast_ballot(ballot.as_json)
        ballots << ballot
      end
    end
    FactoryGirl.create(:session, election_uri: stub_election_uri).tap { |session2|
      session2.ballot_record.cast_ballot(get_ballot(session2).as_json)
    }
  }

  When {
    get "/returns", election: requested_election
  }

  describe "if known election" do
    after(:each) { Timecop.return }

    Given(:requested_election) { election_uri }

    describe "if polls are closed" do
      Given { Timecop.travel(election.pollsClose + 1.day) }

      Then { expect(response).to have_http_status 200 }
      Then { expect(response_json["ballotsIssued"]).to eq nsessions }
      Then { expect(response_json["ballotsCast"]).to eq ncast }
      Then { expect(response_json["ballots"]).to eq ballots.sort.map(&:as_json) }
    end

    describe "if polls are not closed" do
      Given { Timecop.travel(election.pollsClose - 1.day) }
      Then { expect(response).to have_http_status 403 }
      Then { expect(response_error_message).to match /closed/i }
    end
  end

  describe "if not a known election" do
    Given(:requested_election) { stub_election_uri }
    Then { expect(response).to have_http_status 403 }
  end
end
