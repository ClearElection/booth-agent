class CreateBallots < ActiveRecord::Migration
  def change
    create_table :ballot_records do |t|
      t.string  :election_uri,         null: false, index: true
      t.string  :ballotId,             null: false, index: { unique: true, with: :election_uri }
      t.text    :valid_uniquifiers,    null: false
      t.text    :ballot_json
      t.boolean :cast,                 null: false, default: false, index: true
    end

    add_column :sessions, :ballot_record_id, :integer, null: false, index: :unique
    remove_column :sessions, :election_uri

    drop_table :ballot_specs
    drop_table :choices
  end
end
