# == Schema Information
#
# Table name: choices
#
#  id           :integer          not null, primary key
#  election_uri :string(255)      not null, indexed
#  ballotId     :string(255)      not null, indexed
#  uniquifier   :string(255)      not null, indexed
#  contestId    :string(255)      not null, indexed
#  candidateId  :string(255)      not null, indexed
#  rank         :integer
#
# Indexes
#
#  index_choices_on_ballotId      (ballotId)
#  index_choices_on_candidateId   (candidateId)
#  index_choices_on_contestId     (contestId)
#  index_choices_on_election_uri  (election_uri)
#  index_choices_on_uniquifier    (uniquifier)
#

class Choice < ActiveRecord::Base

  def self.create_from_ballot!(ballot, election_uri:)
    ballot.contests.each do |contest|
      contest.choices.each do |choice|
        self.create!(
          election_uri: election_uri,
          contestId: contest.contestId,
          ballotId: contest.ballotId,
          uniquifier: contest.uniquifier,
          candidateId: choice.candidateId,
          rank: choice.rank
        )
      end
    end
  end

  BALLOT_CONTEST_FIELDS = [:contestId, :ballotId, :uniquifier]

  def ballot_contest_attrs
    Hash[BALLOT_CONTEST_FIELDS.map{|field| [field, self.send(field)]}]
  end

  def self.load_ballots(election_uri:)
    self.where(election_uri: election_uri).to_a.group_by(&:ballot_contest_attrs).map { |attrs, choices|
      ClearElection::Ballot.new(
        contests: [
          ClearElection::Ballot::Contest.new(
            attrs.merge(
              choices: choices.sort_by(&:rank).map{|choice|
                ClearElection::Ballot::Choice.new(candidateId: choice.candidateId, rank: choice.rank)
              }
            )
          )
        ]
      )
    }
  end
end
