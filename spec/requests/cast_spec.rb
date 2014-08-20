require "rails_helper"

describe "Cast API" do

  Given(:session) { FactoryGirl.create(:session) }
  Given(:election) { ClearElection::Factory.election(booth: my_uri) }
  Given { stub_request(:get, session.election_uri).to_return body: -> request { election.as_json } }

  Given(:ballot) { get_ballot(session) }

  When {
    post "/cast", sessionKey: session_key, ballot: ballot.as_json
  }

  describe "with valid session key" do
    Given(:session_key) { session.session_key }

    after(:each) { Timecop.return }

    describe "if polls are open" do
      Given { Timecop.travel(election.pollsOpen + 0.5*(election.pollsClose-election.pollsOpen)) }
      describe "with valid ballot" do
        Given(:ballot) { get_ballot(session) }
        Then { expect(response).to have_http_status 204 }
        Then { expect(BallotRecord.where(election_uri: session.election_uri).last.ballot_json).to eq ballot.as_json }
        describe "when cast again" do
          When { post "/cast", sessionKey: session_key, ballot: get_ballot(session) }
          Then { expect(response).to have_http_status 403 }
          Then { expect(response_error_message).to match /cast/i }
        end
      end
    end

    describe "with ballotIds from other ballot" do
      Given(:session2) { FactoryGirl.create(:session, election_uri: session.election_uri) }
      Given(:ballot) { get_ballot(session2) }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_error_message).to match /ballot id/i }
    end

    describe "with nonmatching uniquifier" do
      Given(:ballot) { get_ballot(session, invalid: :uniquifier) }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_error_message).to match /uniquifier/i }
    end

    describe "with invalid choice data" do
      Given(:ballot) { ClearElection::Factory.ballot(session.election, invalid: :candidateId) }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_error_message).to match /candidate id/i }
    end

    describe "with invalid ballot json" do
      Given(:ballot) { {this: { is: :wrong }} }
      Then { expect(response).to have_http_status 422 }
      Then { expect(response_error_message).to match /schema/i }
    end

    context do
      Given(:ballot) { get_ballot(session) }
      describe "if polls haven't opened yet" do
        Given { Timecop.travel(election.pollsOpen - 1.day) }
        Then { expect(response).to have_http_status 403 }
        Then { expect(response_error_message).to match /open/i }
      end

      describe "if polls are closed" do
        Given { Timecop.travel(election.pollsClose + 1.day) }
        Then { expect(response).to have_http_status 403 }
        Then { expect(response_error_message).to match /open/i }
      end
    end
  end

  describe "with invalid session key" do
    Given(:session_key) { "xxx" + session.session_key }
    Then { expect(response).to have_http_status 403 }
    Then { expect(response_error_message).to match /key/i }
  end

end