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

ActiveRecord::Schema.define(version: 20140816103440) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "sessions", force: true do |t|
    t.string  "session_key",                  null: false
    t.string  "election_uri",                 null: false
    t.boolean "cast",         default: false, null: false
    t.index ["election_uri"], :name => "index_sessions_on_election_uri"
    t.index ["session_key"], :name => "index_sessions_on_session_key", :unique => true
  end

  create_table "ballot_specs", force: true do |t|
    t.integer "session_id",  null: false
    t.string  "contestId",   null: false
    t.string  "ballotId",    null: false
    t.text    "uniquifiers"
    t.index ["ballotId", "contestId"], :name => "index_ballot_specs_on_ballotId_and_contestId", :unique => true
    t.index ["session_id"], :name => "fk__ballot_specs_session_id"
    t.foreign_key ["session_id"], "sessions", ["id"], :on_update => :no_action, :on_delete => :no_action, :name => "fk_ballot_specs_session_id"
  end

  create_table "choices", force: true do |t|
    t.string  "election_uri", null: false
    t.string  "ballotId",     null: false
    t.string  "uniquifier",   null: false
    t.string  "contestId",    null: false
    t.string  "candidateId",  null: false
    t.integer "rank"
    t.index ["ballotId"], :name => "index_choices_on_ballotId"
    t.index ["candidateId"], :name => "index_choices_on_candidateId"
    t.index ["contestId"], :name => "index_choices_on_contestId"
    t.index ["election_uri"], :name => "index_choices_on_election_uri"
    t.index ["uniquifier"], :name => "index_choices_on_uniquifier"
  end

end
