class AddCastToSession < ActiveRecord::Migration
  def change
    add_column :sessions, :cast, :boolean, null: false, default: false
  end
end
