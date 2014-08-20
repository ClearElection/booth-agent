class SessionSerializer < ActiveModel::Serializer

  attribute :session_key, key: :sessionKey
  has_one :ballot_record, key: :ballot

end
