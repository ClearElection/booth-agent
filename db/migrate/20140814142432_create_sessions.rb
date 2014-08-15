class CreateSessions < ActiveRecord::Migration
  def change
    create_table :sessions do |t|
      t.string :session_key, null: false, index: :unique
    end
  end
end
