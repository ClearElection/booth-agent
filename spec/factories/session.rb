FactoryGirl.define do

  factory :session, :class => Session do
    sequence(:session_key) { |n| "Session_key_#{n}" }
    sequence(:election_uri) { |n| "http://dummy.example.com/election/#{n}/" }
    election { ClearElection::Factory.election }
  end
end
