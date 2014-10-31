# == Schema Information
#
# Table name: ballot_records
#
#  ballotId          :string(255)      not null, indexed => [election_uri]
#  ballot_json       :text
#  cast              :boolean          default(FALSE), not null, indexed
#  demographic       :text
#  election_uri      :string(255)      not null, indexed => [ballotId], indexed
#  id                :integer          not null, primary key
#  valid_uniquifiers :text             not null
#
# Indexes
#
#  index_ballot_records_on_ballotId_and_election_uri  (ballotId,election_uri) UNIQUE
#  index_ballot_records_on_cast                       (cast)
#  index_ballot_records_on_election_uri               (election_uri)
#

BALLOT_ID_CHARS = "BCDFGHJKLMNPQRSTVWXZ0123456789".split('')
UNIQUIFIER_CHARS = "bcdfghjkmnpqrstvwxz0123456789".split('')

class BallotRecord < ActiveRecord::Base
  serialize :valid_uniquifiers, JSON
  serialize :ballot_json, JSON
  serialize :demographic, JSON

  before_validation on: :create do
    self.ballotId ||= new_ballotId
    self.valid_uniquifiers ||= 10.times.map { new_uniquifier }
  end

  validates_presence_of :ballot_json, if: :cast, strict: true
  validate :validate_ballot_json

  def new_ballotId
    while true do
      newId = 10.times.map{BALLOT_ID_CHARS.sample}.join
      return newId if not self.class.where(election_uri: self.election_uri, :ballotId => newId).exists?
    end
  end

  def new_uniquifier
    return 8.times.map{UNIQUIFIER_CHARS.sample}.join
  end

  def election
    @election ||= ClearElection.read(election_uri)
  end

  def ballot
    @ballot ||= ClearElection::Ballot.from_json(ballot_json) if ballot_json
  end

  def validate_ballot_json
    if ballot_json
      ballot.validate(election)
      ballot.errors << { ballotId: ballot.ballotId, message: "invalid ballot ID" } unless ballot.ballotId == self.ballotId
      ballot.errors << { uniquifier: ballot.uniquifier, message: "invalid uniquifier" } unless self.valid_uniquifiers.include?(ballot.uniquifier)
      ballot.errors.each do |err|
        self.errors.add(:ballot_json, err)
      end
    end
  end

  def cast_ballot(ballot_json)
    self.ballot_json = ballot_json.as_json
    self.cast = true
    self.save
  end


end
