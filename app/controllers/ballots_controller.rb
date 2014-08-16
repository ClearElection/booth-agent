class BallotsController < ApplicationController
  def create
    session = Session.where(session_key: params[:sessionKey]).first
    
    if session.nil?
      render json: { error: "invalid session key" }, status: 403
      return
    end

    if session.cast?
      render json: { error: "ballot has already been cast" }, status: 403
      return
    end

    election = session.election

    unless election.polls_are_now_open?
      render json: { error: "polls are not open" }, status: 403
      return
    end

    ballot = ClearElection::Ballot.from_json(params[:ballot])

    ballot.validate(election)

    ballot.contests.each do |contest|
      ballot_spec = session.get_ballot_spec(contestId: contest.contestId)
      if not ballot_spec.ballotId == contest.ballotId
        ballot.errors.push contestId: contest.contestId, ballotId: contest.ballotId, message: "Invalid ballot id"
      end
      if not ballot_spec.uniquifiers.include? contest.uniquifier
        ballot.errors.push contestId: contest.contestId, ballotId: contest.ballotId, uniquifier: contest.uniquifier, message: "invalid uniquifier"
      end
    end

    if not ballot.valid?
      render json: { errors: ballot.errors }, status: 422
      return
    end

    session.cast!(ballot)

    render json: {}, status: 204
  end
end
