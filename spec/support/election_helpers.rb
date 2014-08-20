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
    stub_request(:get, election_uri).to_return body: (election || ClearElection::Factory.election(booth: my_uri)).as_json
    election_uri
  end

  def my_uri
    @my_uri ||= ClearElection::Factory.agent_uri("booth")
  end

  def my_uri_hack
    # For testing pretend that all requests are prefixed with my_uri's host & path
    host! URI(my_uri).host
    allow_any_instance_of(ActionDispatch::Request).to receive(:original_url) { |request|
      request.base_url + URI(my_uri).path + request.original_fullpath
    }
  end

end
