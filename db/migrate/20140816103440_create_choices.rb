class CreateChoices < ActiveRecord::Migration
  def change
    create_table :choices do |t|
      t.string :election_uri,   index: true, null: false
      t.string :ballotId,       index: true, null: false
      t.string :uniquifier,     index: true, null: false
      t.string :contestId,      index: true, null: false
      t.string :candidateId,    index: true, null: false
      t.integer :rank
    end
  end
end
