class SessionSerializer < ActiveModel::Serializer

  attribute :session_key, key: :sessionKey
  has_many :ballot_specs, key: :ballot

end
