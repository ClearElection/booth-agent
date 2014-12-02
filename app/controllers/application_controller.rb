class ApplicationController < ActionController::API

  # create a session (issues a ballot)
  def session
    election_uri = params[:election]
    accessToken = params[:accessToken]
    election = ClearElection.read(election_uri) rescue nil

    return unless check_election(election, now: :open)

    response = Faraday.post(election.signin.uri + "redeem", election: election_uri, accessToken: accessToken)
    if not response.success?
      render json: { error: "failed to redeem accessToken", signinResponse: response}, status: 403
      return
    end

    session = Session.create!(election_uri: election_uri, demographic: JSON.parse(response.body)['demographic'])
    render json: session, root: nil
  end

  # cast the ballot in a session
  def cast
    unless (session = Session.where(session_key: params[:sessionKey]).first)
      render json: { error: "invalid session key" }, status: 403
      return
    end

    return unless check_election(session.election, now: :open)

    ballot_record = session.ballot_record

    if ballot_record.cast?
      render json: { error: "ballot has already been cast" }, status: 403
      return
    end

    if !ballot_record.cast_ballot(params[:ballot])
      render json: { errors: ballot_record.errors[:ballot_json] }, status: 422
      return
    end

    render nothing: true, status: 204
  end

  # get the returns data
  def returns
    election_uri = params[:election]
    return unless check_election(ClearElection.read(election_uri), now: :closed)

    ballot_records = BallotRecord.where(election_uri: election_uri)

    render json: {
      ballotsIssued: ballot_records.count,
      ballotsCast: ballot_records.where(cast: true).count,
      ballots: ballot_records.where(cast: true).order(:ballotId).pluck(:ballot_json, :demographic).map{|ballot_json, demographic| demographic ? ballot_json.merge(demographic: demographic) : ballot_json}
    }, status: 200

  end

  private

  def check_election(election, now:)
    if election.nil?
      render json: { error: "invalid election uri" }, status: 422
      return false
    end

    my_uri = URI(request.original_url)
    unless my_uri.host == election.booth.uri.host and my_uri.path.start_with? election.booth.uri.path
      render json: { error: "not designated booth agent" }, status: 422
      return false
    end

    case now
    when :open
      unless election.polls_are_now_open?
        render json: { error: "polls are not open" }, status: 403
        return false
      end
    when :closed
      unless election.polls_are_now_closed?
        render json: { error: "polls are not closed" }, status: 403
        return false
      end
    end

    return true
  end

end
