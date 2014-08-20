FactoryGirl.define do

  factory :session, :class => Session do
    election_uri { ClearElection::Factory.election_uri }
  end
end
