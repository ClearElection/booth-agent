class ReturnsController < ApplicationController
  def show
    election_uri = params[:election]

    ballot_records = BallotRecord.where(election_uri: election_uri)

    if !ballot_records.exists?
      render json: { error: "no returns data" }, status: 404
      return
    end

    election = ClearElection.read(election_uri)

    unless election.polls_are_now_closed?
      render json: { error: "polls are not closed" }, status: 403
      return
    end

    render json: {
      ballotsIssued: ballot_records.count,
      ballotsCast: ballot_records.where(cast: true).count,
      ballots: ballot_records.where(cast: true).order(:ballotId).pluck(:ballot_json)
    }, status: 200

  end
end

