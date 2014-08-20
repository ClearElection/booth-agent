module ElectionHelpers
  def get_ballot(session, invalid: nil)
    ClearElection::Factory.ballot(
      session.election,
      ballotId: session.ballot_record.ballotId, 
      uniquifier: (invalid == :uniquifier) ? "an-invalid-uniquifier" : session.ballot_record.valid_uniquifiers.sample,
      invalid: invalid
    )
  end

  def stub_election_uri(election=nil)
    election_uri = ClearElection::Factory.election_uri
    stub_request(:get, election_uri).to_return body: (election || ClearElection::Factory.election).as_json
    election_uri
  end
end
