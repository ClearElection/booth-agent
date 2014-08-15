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

    response = Faraday.post(election.registrar.uri + "redeem", election_uri: election_uri, accessToken: accessToken)
    if response.status != 200
      render json: { error: "failed to redeem accessToken", registrarResponse: response}, status: 403
      return
    end

    session = Session.create!(election: election)
    render json: session, root: nil
  end
end

