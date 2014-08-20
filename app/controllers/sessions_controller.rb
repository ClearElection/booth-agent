class SessionsController < ApplicationController
  def create
    election_uri = params[:election]
    accessToken = params[:accessToken]
    election = ClearElection.read(election_uri) rescue nil

    if election.nil?
      render json: { error: "invalid election uri" }, status: 422
      return
    end

    my_uri = URI(request.original_url)
    unless my_uri.host == election.booth.uri.host and my_uri.path.start_with? election.booth.uri.path
      render json: { error: "not designated booth agent" }, status: 422
      return
    end

    unless election.polls_are_now_open?
      render json: { error: "polls are not open" }, status: 403
      return
    end

    response = Faraday.post(election.signin.uri + "redeem", election_uri: election_uri, accessToken: accessToken)
    if not response.success?
      render json: { error: "failed to redeem accessToken", signinResponse: response}, status: 403
      return
    end

    session = Session.create!(election: election)
    render json: session, root: nil
  end
end

