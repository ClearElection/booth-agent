class AddDemographicToBallotRecords < ActiveRecord::Migration
  def change
    add_column :ballot_records, :demographic, :text
  end
end
