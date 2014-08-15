class AddElectionUriToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :election_uri, :string, null: false, index: true
  end
end
