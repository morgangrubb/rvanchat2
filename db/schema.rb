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

ActiveRecord::Schema.define(version: 20150906164017) do

  create_table "backgrounds", force: :cascade do |t|
    t.string   "url",        limit: 255
    t.string   "credit",     limit: 255
    t.datetime "created_at",             null: false
    t.datetime "updated_at",             null: false
  end

  create_table "group_users", force: :cascade do |t|
    t.integer  "group_id",   limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "group_users", ["group_id"], name: "index_group_users_on_group_id", using: :btree
  add_index "group_users", ["user_id"], name: "index_group_users_on_user_id", using: :btree

  create_table "groups", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.boolean  "default",    limit: 1,   default: false
    t.datetime "created_at",                             null: false
    t.datetime "updated_at",                             null: false
  end

  create_table "links", force: :cascade do |t|
    t.integer  "message_id", limit: 4,     null: false
    t.string   "host",       limit: 255,   null: false
    t.text     "url",        limit: 65535, null: false
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "links", ["created_at"], name: "index_links_on_created_at", using: :btree
  add_index "links", ["message_id"], name: "index_links_on_message_id", using: :btree

  create_table "messages", force: :cascade do |t|
    t.string   "user_name",  limit: 255
    t.integer  "user_id",    limit: 4
    t.string   "room_name",  limit: 255
    t.integer  "room_id",    limit: 4
    t.text     "text",       limit: 65535
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
  end

  add_index "messages", ["room_id", "created_at"], name: "index_messages_on_room_id_and_created_at", using: :btree
  add_index "messages", ["user_id", "created_at"], name: "index_messages_on_user_id_and_created_at", using: :btree

  create_table "room_users", force: :cascade do |t|
    t.integer  "room_id",    limit: 4
    t.integer  "user_id",    limit: 4
    t.datetime "created_at",           null: false
    t.datetime "updated_at",           null: false
  end

  add_index "room_users", ["user_id"], name: "index_room_users_on_user_id", using: :btree

  create_table "rooms", force: :cascade do |t|
    t.string   "name",       limit: 255
    t.datetime "created_at",                            null: false
    t.datetime "updated_at",                            null: false
    t.boolean  "default",    limit: 1,   default: true, null: false
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255,   default: "",    null: false
    t.string   "encrypted_password",     limit: 255,   default: "",    null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          limit: 4,     default: 0,     null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "provider",               limit: 255
    t.string   "uid",                    limit: 255
    t.string   "name",                   limit: 255
    t.string   "xmpp_username",          limit: 255
    t.string   "xmpp_password",          limit: 255
    t.boolean  "admin",                  limit: 1,     default: false, null: false
    t.string   "image_url",              limit: 255
    t.text     "auth_info",              limit: 65535
    t.string   "admin_token",            limit: 255
  end

  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  add_index "users", ["xmpp_username"], name: "index_users_on_xmpp_username", unique: true, using: :btree

end
