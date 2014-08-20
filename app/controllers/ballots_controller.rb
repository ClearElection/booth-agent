class BallotsController < ApplicationController
  def create
    session = Session.where(session_key: params[:sessionKey]).first
    
    if session.nil?
      render json: { error: "invalid session key" }, status: 403
      return
    end

    election = session.election

    ballot_record = session.ballot_record

    if ballot_record.cast?
      render json: { error: "ballot has already been cast" }, status: 403
      return
    end

    unless election.polls_are_now_open?
      render json: { error: "polls are not open" }, status: 403
      return
    end

    ballot_record.ballot_json = params[:ballot]

    if not ballot_record.valid?
      render json: { errors: ballot_record.errors[:ballot_json] }, status: 422
      return
    end

    ballot_record.cast!

    render json: {}, status: 204
  end
end
