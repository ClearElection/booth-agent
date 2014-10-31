require "rails_helper"

describe "Flow" do
  let(:nElections) { 3 }
  let(:nAccess) { 5 }
  let(:nCast) { 3 }

  it "creates sessions, casts ballots, and has corret returns data for multiple elections" do

    nElections.times do
      election = ClearElection::Factory.election booth: my_agent_uri
      electionUri = stub_election_uri election: election

      accessTokens = nAccess.times.map { stub_access_token(election_uri: electionUri) }

      sessions = accessTokens.each_with_index.map { |accessToken, i|
        post "/session", election: electionUri, accessToken: accessToken
        expect(response).to have_http_status 200
        sessionKey = response_json["sessionKey"]
        ballotId = response_json["ballot"]["ballotId"]
        uniquifiers = response_json["ballot"]["uniquifiers"]
        [sessionKey, ballotId, uniquifiers]
      }


      ballots = sessions.take(nCast).map { |sessionKey, ballotId, uniquifiers|
        ballot = ClearElection::Factory.ballot election, ballotId: ballotId, uniquifier: uniquifiers.sample
        post "/cast", sessionKey: sessionKey, ballot: ballot.as_json
        expect(response).to have_http_status 204
        ballot
      }

      Timecop.travel(election.pollsClose + 1.day) do
        get "/returns", election: electionUri
        expect(response).to have_http_status 200
        expect(response_json["ballotsIssued"]).to eq nAccess
        expect(response_json["ballotsCast"]).to eq nCast
      end
    end
  end
end
