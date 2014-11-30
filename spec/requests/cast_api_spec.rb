require "rails_helper"

describe "Cast API" do

  def post_cast(session_key, ballot)
    post "/cast", sessionKey: session_key, ballot: ballot.as_json
  end

  let(:election_uri) { stub_election_uri(booth: my_agent_uri) }
  let(:election) { ClearElection.read(election_uri) }
  let(:session) { FactoryGirl.create(:session, election_uri: election_uri) }

  let(:valid_session_key) { session.session_key }
  let(:invalid_session_key) { "xxx" + session.session_key }

  describe "with valid session key" do

    it "accepts valid ballot" do
      post_cast valid_session_key, filled_ballot(session)
      expect(response).to have_http_status 204
    end

    it "rejects session reuse" do
      post_cast valid_session_key, filled_ballot(session)
      expect(response).to have_http_status 204
      post_cast valid_session_key, filled_ballot(session)
      expect(response).to have_http_status 403
      expect(response_error_message).to match /cast/i
    end

    it "rejects ballotIds from other ballot" do
      other_session = FactoryGirl.create(:session, election_uri: election_uri)
      post_cast valid_session_key, filled_ballot(other_session)
      expect(response).to have_http_status 422
      expect(response_error_message).to match /ballot id/i
    end

    it "rejects nonmatching uniquifier" do
      post_cast valid_session_key, filled_ballot(session, invalid: :uniquifier)
      expect(response).to have_http_status 422
      expect(response_error_message).to match /uniquifier/i
    end

    it "rejects invalid choice data" do
      post_cast valid_session_key, filled_ballot(session, invalid: :candidateId)
      expect(response).to have_http_status 422
      expect(response_error_message).to match /candidate id/i
    end

    it "rejects invalid ballot json" do
      post_cast valid_session_key, {this: { is: :wrong }}
      expect(response).to have_http_status 422
      expect(response_error_message).to match /schema/i
    end

    it_behaves_like "api that verifies election state", :open do
      let(:election) { ClearElection.read(election_uri) }
      let(:api_bound) { -> { post_cast valid_session_key, filled_ballot(session) } }
    end
  end

  it "rejects invalid session key" do
    post_cast invalid_session_key, filled_ballot(session)
    expect(response).to have_http_status 403
    expect(response_error_message).to match /key/i
  end

end
