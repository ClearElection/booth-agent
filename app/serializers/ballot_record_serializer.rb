class BallotRecordSerializer < ActiveModel::Serializer

  attribute :ballotId
  attribute :valid_uniquifiers, key: :uniquifiers

end
