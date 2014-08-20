# == Schema Information
#
# Table name: sessions
#
#  id               :integer          not null, primary key
#  session_key      :string(255)      not null, indexed
#  election_uri     :string(255)      not null, indexed
#  cast             :boolean          default(FALSE), not null
#  ballot_record_id :integer          not null, indexed
#
# Indexes
#
#  index_sessions_on_ballot_record_id  (ballot_record_id) UNIQUE
#  index_sessions_on_election_uri      (election_uri)
#  index_sessions_on_session_key       (session_key) UNIQUE
#

class Session < ActiveRecord::Base

  attr_writer :election_uri
  delegate :election, :election_uri, to: :ballot_record

  before_validation on: :create do
    self.session_key ||= self.class.new_session_key
    self.ballot_record ||= BallotRecord.create(election_uri: @election_uri)
  end

  def self.new_session_key
    while true do
      session_key = SecureRandom.base64(32)
      return session_key if not self.where(session_key: session_key).exists?
    end
  end

end
