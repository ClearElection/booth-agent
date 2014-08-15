class CreateBallotSpec < ActiveRecord::Migration
  def change
    create_table :ballot_specs do |t|
      t.references :session, null: false
      t.string :contestId, null: false
      t.string :ballotId, null: false, index: { with: :contestId, unique: true }
      t.text :uniquifiers 
    end
  end
end
