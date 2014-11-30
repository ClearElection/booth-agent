require "rails_helper"

describe "Returns API" do

  it_behaves_like "api validates election URI", agent: :booth, state: :closed do
    let(:apicall) { -> election_uri { get "/returns", election: election_uri} }
  end

end
