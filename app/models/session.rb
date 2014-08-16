# == Schema Information
#
# Table name: sessions
#
#  id           :integer          not null, primary key
#  session_key  :string(255)      not null, indexed
#  election_uri :string(255)      not null, indexed
#  cast         :boolean          default(FALSE), not null
#
# Indexes
#
#  index_sessions_on_election_uri  (election_uri)
#  index_sessions_on_session_key   (session_key) UNIQUE
#

class Session < ActiveRecord::Base

  attr_writer :election

  before_validation on: :create do
    self.session_key ||= self.class.new_session_key
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

  def get_ballot_spec(contestId:)
    self.ballot_specs.where(contestId: contestId).first
  end

  def self.new_session_key
    while true do
      session_key = SecureRandom.base64(32)
      return session_key if not self.where(session_key: session_key).exists?
    end
  end

  def cast!(ballot)
    self.class.transaction do
      Choice.create_from_ballot!(ballot, election_uri: election_uri)
      self.update_attributes!(cast: true)
    end
  end


end
