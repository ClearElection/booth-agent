require "rails_helper"

describe "Function" do
  let(:nElections) { 3 }
  let(:nAccess) { 10 }
  let(:nCast) { 8 }

  let (:electionUris) { nElections.times.map { stub_election_uri booth: my_agent_uri } }

  it "creates sessions, casts ballots, and has correct returns data for multiple elections" do

    sessions = {}
    ballots = {}

    electionUris.each do |electionUri|
      accessTokens = nAccess.times.map { |i| stub_election_access_token election_uri: electionUri, demographic: {"parity" => i.even? ? "even" : "odd" } }
      sessions[electionUri] = accessTokens.each_with_index.map { |accessToken, i|
        json_request :post, "/session", election: electionUri, accessToken: accessToken
        expect(response).to have_http_status 200
        sessionKey = response_json["sessionKey"]
        ballotId = response_json["ballot"]["ballotId"]
        uniquifiers = response_json["ballot"]["uniquifiers"]
        [sessionKey, ballotId, uniquifiers]
      }
    end

    electionUris.each do |electionUri|
      election = ClearElection.read(electionUri)
      ballots[electionUri] = sessions[electionUri].take(nCast).map { |sessionKey, ballotId, uniquifiers|
        ballot = ClearElection::Factory.ballot election, ballotId: ballotId, uniquifier: uniquifiers.sample
        json_request :post, "/cast", sessionKey: sessionKey, ballot: ballot.as_json
        expect(response).to have_http_status 204
        ballot
      }
    end

    electionUris.each do |electionUri|
      election = ClearElection.read(electionUri)
      Timecop.travel(election.pollsClose + 1.day) do
        json_request :get, "/returns", election: electionUri
        expect(response).to have_http_status 200
        expect(response_json["ballotsIssued"]).to eq nAccess
        expect(response_json["ballotsCast"]).to eq nCast
        returns = response_json["ballots"]
        expect(returns.map{ |json| json.except("demographic") }).to eq ballots[electionUri].sort.map(&:as_json)
        grouped = returns.group_by{|json| json["demographic"]["parity"]}
        expect(grouped.size).to eq 2
        expect(grouped["even"].size).to eq nCast/2
        expect(grouped["odd"].size).to eq nCast/2
      end
    end
  end
end
