module BoothHelpers
  def filled_ballot(session, invalid: nil)
    ballot_record = session.ballot_record
    ClearElection::Factory.ballot(
      ballot_record.election,
      ballotId: ballot_record.ballotId, 
      uniquifier: (invalid == :uniquifier) ? "an-invalid-uniquifier" : ballot_record.valid_uniquifiers.sample,
      invalid: invalid
    )
  end

  def json_request(method, name, args)
    args = args.to_json if method == :post
    send method, name, args, { 'Content-Type' => 'application/json' }
  end

end
