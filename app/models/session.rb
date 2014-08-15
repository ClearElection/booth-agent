# == Schema Information
#
# Table name: sessions
#
#  id           :integer          not null, primary key
#  session_key  :string(255)      not null
#  election_uri :string(255)      not null


class Session < ActiveRecord::Base

  attr_writer :election

  before_validation on: :create do
    self.session_key = self.class.new_session_key
    self.election_uri ||= @election.uri if @election
  end

  after_create :create_ballot_specs

  def election
    @election ||= ClearElection.read(election_uri)
  end

  def create_ballot_specs
    election.contests.each do |contest|
      BallotSpec.create!(session: self, contestId: contest.contestId)
    end
  end

  def self.new_session_key
    while true do
      session_key = SecureRandom.base64(32)
      return session_key if self.where(session_key: session_key).count == 0
    end
  end

end
