# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20140820084911) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "ballot_records", force: true do |t|
    t.string  "election_uri",                      null: false
    t.string  "ballotId",                          null: false
    t.text    "valid_uniquifiers",                 null: false
    t.text    "ballot_json"
    t.boolean "cast",              default: false, null: false
    t.index ["ballotId", "election_uri"], :name => "index_ballot_records_on_ballotId_and_election_uri", :unique => true
    t.index ["cast"], :name => "index_ballot_records_on_cast"
    t.index ["election_uri"], :name => "index_ballot_records_on_election_uri"
  end

  create_table "sessions", force: true do |t|
    t.string  "session_key",                      null: false
    t.boolean "cast",             default: false, null: false
    t.integer "ballot_record_id",                 null: false
    t.index ["ballot_record_id"], :name => "index_sessions_on_ballot_record_id", :unique => true
    t.index ["session_key"], :name => "index_sessions_on_session_key", :unique => true
    t.foreign_key ["ballot_record_id"], "ballot_records", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_sessions_ballot_record_id"
  end

end
