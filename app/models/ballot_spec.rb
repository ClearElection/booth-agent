# == Schema Information
#
# Table name: ballot_specs
#
#  id          :integer          not null, primary key
#  session_id  :integer          not null, indexed
#  contestId   :string(255)      not null, indexed => [ballotId]
#  ballotId    :string(255)      not null, indexed => [contestId]
#  uniquifiers :text
#
# Indexes
#
#  fk__ballot_specs_session_id                   (session_id)
#  index_ballot_specs_on_ballotId_and_contestId  (ballotId,contestId) UNIQUE
#

BALLOT_ID_CHARS = "BCDFGHJKLMNPQRSTVWXZ0123456789".split('')
UNIQUIFIER_CHARS = "bcdfghjkmnpqrstvwxz0123456789".split('')

class BallotSpec < ActiveRecord::Base
  delegate :election_uri, to: :session

  scope :for_election, -> election_uri { joins(:session).where(sessions: { election_uri: election_uri }) }

  serialize :uniquifiers, JSON

  before_validation on: :create do
    self.ballotId ||= new_ballotId
    self.uniquifiers ||= 10.times.map { new_uniquifier }
  end

  def new_ballotId
    while true do
      newId = 10.times.map{BALLOT_ID_CHARS.sample}.join
      return newId if not self.class.for_election(election_uri).where(contestId: self.contestId, :ballotId => newId).exists?
    end
  end

  def new_uniquifier
    return 8.times.map{UNIQUIFIER_CHARS.sample}.join
  end

end
