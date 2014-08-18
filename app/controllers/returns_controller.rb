class ReturnsController < ApplicationController
  def show
    election_uri = params[:election]

    sessions = Session.where(election_uri: election_uri)

    if !sessions.exists?
      render json: { error: "no returns data" }, status: 404
      return
    end

    election = ClearElection.read(election_uri)

    unless election.polls_are_now_closed?
      render json: { error: "polls are not closed" }, status: 403
      return
    end

    ballots = Choice.load_ballots(election_uri: election_uri)

    render json: {
      ballotsIssued: sessions.count,
      ballotsCast: sessions.where(cast: true).count,
      ballots: ballots.sort.map(&:as_json)
    }, status: 200

  end
end

