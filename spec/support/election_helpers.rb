module ElectionHelpers
  def get_ballot(session, invalid: nil)
    ClearElection::Factory.ballot(session.election, identify: -> contest {
      ballot_spec = session.get_ballot_spec(contestId: contest.contestId)
      ballotId = ballot_spec.ballotId
      uniquifier = ballot_spec.uniquifiers.sample
      uniquifier = "i-am-invalid" if invalid == :uniquifier
      [ballotId, uniquifier]
    }, invalid: invalid)
  end
end
