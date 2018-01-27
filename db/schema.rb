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

ActiveRecord::Schema.define(version: 20171203093524) do

  create_table "achievement_pursuits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "slug"
    t.integer "progress"
    t.integer "user_id"
    t.index ["user_id"], name: "index_achievement_pursuits_on_user_id"
  end

  create_table "achievement_receivers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "achievement_id"
    t.index ["achievement_id"], name: "index_achievement_receivers_on_achievement_id"
    t.index ["user_id"], name: "index_achievement_receivers_on_user_id"
  end

  create_table "achievements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "slug"
    t.string "name"
    t.string "description"
  end

  create_table "actions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "action"
    t.text "text", limit: 4294967295
    t.integer "appeal_id"
    t.integer "user_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["appeal_id"], name: "index_actions_on_appeal_id"
  end

  create_table "alerts", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "name"
    t.string "message"
    t.string "url"
    t.integer "seen", default: 0
    t.datetime "created_at"
  end

  create_table "announcements", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "body"
    t.boolean "motd"
    t.boolean "lobby"
    t.boolean "tips"
    t.boolean "web"
    t.boolean "popup"
    t.string "permission"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "motd_format"
    t.boolean "enabled"
  end

  create_table "appeals", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "punishment_id"
    t.boolean "open"
    t.boolean "locked"
    t.boolean "appealed"
    t.boolean "escalated"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "backpack_gadgets", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "gadget_type"
    t.text "gadget"
    t.text "context"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "old_id"
    t.index ["user_id"], name: "index_backpack_gadgets_on_user_id"
  end

  create_table "blazer_audits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "query_id"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
  end

  create_table "blazer_checks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "creator_id"
    t.integer "query_id"
    t.string "state"
    t.string "schedule"
    t.text "emails"
    t.string "check_type"
    t.text "message"
    t.datetime "last_run_at"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboard_queries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "dashboard_id"
    t.integer "query_id"
    t.integer "position"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_dashboards", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "creator_id"
    t.text "name"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "blazer_queries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "creator_id"
    t.string "name"
    t.text "description"
    t.text "statement"
    t.string "data_source"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "categories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.integer "priority"
    t.integer "forum_id"
    t.string "desc"
    t.text "tags"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "exclude_from_recent"
    t.string "uuid"
    t.index ["forum_id"], name: "index_categories_on_forum_id"
  end

  create_table "credits", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "game_id"
    t.integer "amount"
    t.string "weight", limit: 3
    t.datetime "created_at"
    t.index ["user_id"], name: "user_id"
  end

  create_table "deaths", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "cause"
    t.integer "game_id"
    t.datetime "created_at"
    t.boolean "user_hidden", default: false
    t.boolean "cause_hidden", default: false
    t.index ["cause"], name: "cause"
    t.index ["cause_hidden"], name: "index_deaths_on_cause_hidden"
    t.index ["game_id"], name: "game_id"
    t.index ["user_hidden"], name: "index_deaths_on_user_hidden"
    t.index ["user_id"], name: "user_id"
  end

  create_table "discussions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "archived", default: 0
    t.integer "stickied", default: 0
    t.integer "category_id"
    t.string "uuid"
    t.integer "views", default: 0
    t.index ["category_id"], name: "category_id"
    t.index ["created_at"], name: "created_at"
  end

  create_table "experience_leaderboard_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "period"
    t.integer "level"
    t.integer "prestige_level"
    t.integer "xp_total"
    t.integer "xp_nebula"
    t.integer "xp_koth"
    t.integer "xp_ctf"
    t.integer "xp_tdm"
    t.integer "xp_elimination"
    t.integer "xp_sw"
    t.integer "xp_walls"
    t.integer "xp_arcade"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_experience_leaderboard_entries_on_user_id"
  end

  create_table "experience_transactions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "season_id"
    t.integer "amount"
    t.string "weight"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "genre"
  end

  create_table "forums", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.integer "priority"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "friends", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "friend_id"
    t.integer "accepted"
    t.datetime "created_at"
  end

  create_table "impressions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "impressionable_type"
    t.integer "impressionable_id"
    t.integer "user_id"
    t.string "controller_name"
    t.string "action_name"
    t.string "view_name"
    t.string "request_hash"
    t.string "ip_address"
    t.string "session_hash"
    t.text "message"
    t.text "referrer"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "params"
    t.index ["controller_name", "action_name", "ip_address"], name: "controlleraction_ip_index"
    t.index ["controller_name", "action_name", "request_hash"], name: "controlleraction_request_index"
    t.index ["controller_name", "action_name", "session_hash"], name: "controlleraction_session_index"
    t.index ["impressionable_type", "impressionable_id", "ip_address"], name: "poly_ip_index"
    t.index ["impressionable_type", "impressionable_id", "params"], name: "poly_params_request_index", length: { params: 255 }
    t.index ["impressionable_type", "impressionable_id", "request_hash"], name: "poly_request_index"
    t.index ["impressionable_type", "impressionable_id", "session_hash"], name: "poly_session_index"
    t.index ["impressionable_type", "message", "impressionable_id"], name: "impressionable_type_message_index", length: { message: 255 }
    t.index ["user_id"], name: "index_impressions_on_user_id"
  end

  create_table "ip_bans", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "staff_id"
    t.string "reason"
    t.string "ip"
    t.boolean "enabled"
    t.datetime "created_at"
    t.string "excluded_users"
  end

  create_table "leaderboard_entries", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "period"
    t.integer "kills"
    t.integer "deaths"
    t.float "kd_ratio", limit: 24
    t.integer "monuments"
    t.integer "wools"
    t.integer "flags"
    t.integer "hills"
    t.integer "score"
    t.integer "time_online"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "index_leaderboard_entries_on_user_id"
  end

  create_table "livestreams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "channel"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "map_ratings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "map_slug"
    t.string "map_version"
    t.integer "player"
    t.integer "rating"
    t.string "feedback"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "memberships", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "rank_id"
    t.integer "member_id"
    t.datetime "expires_at"
    t.boolean "is_purchased", default: false
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string "role"
    t.index ["rank_id"], name: "index_memberships_on_rank_id"
  end

  create_table "messages", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "sender_id"
    t.integer "receiver_id"
    t.text "content"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["receiver_id"], name: "index_messages_on_receiver_id"
    t.index ["sender_id"], name: "index_messages_on_sender_id"
  end

  create_table "objective_types", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "game_id"
    t.string "name"
  end

  create_table "objectives", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "objective_id"
    t.datetime "created_at"
    t.boolean "hidden", default: false
    t.index ["hidden"], name: "index_objectives_on_hidden"
    t.index ["user_id"], name: "user_id"
  end

  create_table "present_finders", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.bigint "user_id"
    t.bigint "present_id"
    t.index ["present_id"], name: "index_present_finders_on_present_id"
    t.index ["user_id"], name: "index_present_finders_on_user_id"
  end

  create_table "presents", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8" do |t|
    t.string "slug"
    t.string "family"
    t.string "human_name"
    t.string "human_location"
    t.datetime "found_at"
  end

  create_table "prestige_levels", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "season_id"
    t.integer "level"
  end

  create_table "prestige_seasons", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "multiplier"
    t.datetime "start_at"
    t.datetime "end_at"
  end

  create_table "punishments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "staff_id"
    t.string "type"
    t.string "reason"
    t.datetime "date"
    t.datetime "expires"
    t.integer "appealed", default: 0
    t.integer "server_id"
    t.boolean "silent"
    t.index ["server_id"], name: "index_punishments_on_server_id"
  end

  create_table "purchases", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "p_id", default: 0
    t.integer "duration"
    t.integer "expired", default: 0
    t.integer "spent", default: 0
    t.datetime "created_at"
    t.string "product_id"
    t.text "data"
  end

  create_table "ranks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.text "mc_perms"
    t.text "web_perms", limit: 4294967295
    t.boolean "is_staff", default: false
    t.string "html_color", default: "none"
    t.string "badge_color", default: "none"
    t.string "badge_text_color", default: "white"
    t.string "mc_prefix", default: ""
    t.string "mc_suffix", default: ""
    t.integer "priority", default: 0
    t.text "special_perms"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "inheritance_id"
    t.text "ts_perms"
  end

  create_table "read_marks", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "readable_id"
    t.integer "user_id", null: false
    t.string "readable_type", limit: 20, null: false
    t.datetime "timestamp"
    t.index ["user_id", "readable_type", "readable_id"], name: "index_read_marks_on_user_id_and_readable_type_and_readable_id"
  end

  create_table "registrations", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "tournament_id"
    t.integer "team_id"
    t.text "user_data"
    t.integer "status"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["team_id"], name: "index_registrations_on_team_id"
    t.index ["tournament_id"], name: "index_registrations_on_tournament_id"
  end

  create_table "replies", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "discussion_id"
    t.datetime "created_at"
    t.integer "user_id"
    t.integer "reply_id"
    t.index ["created_at"], name: "created_at"
  end

  create_table "reports", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "creator_id"
    t.string "reason"
    t.string "server"
    t.datetime "created_at"
  end

  create_table "reserved_slots", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "team_id"
    t.string "server"
    t.datetime "created_at"
    t.datetime "start_at"
    t.datetime "end_at"
    t.integer "reservee"
  end

  create_table "revisions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "reply_id"
    t.integer "discussion_id"
    t.string "title"
    t.text "body", limit: 16777215
    t.integer "category_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer "user_id"
    t.integer "archived", default: 0
    t.integer "deleted", default: 0
    t.integer "stickied", default: 0
    t.integer "locked", default: 0
    t.integer "active", default: 0
    t.integer "original", default: 0
    t.string "tag"
    t.boolean "sanctioned", default: false
    t.index ["active"], name: "active"
    t.index ["discussion_id"], name: "discussion_id"
    t.index ["original"], name: "original"
    t.index ["reply_id"], name: "reply_id"
  end

  create_table "server_boosters", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "server_id"
    t.decimal "multiplier", precision: 10
    t.datetime "starts_at"
    t.datetime "expires_at"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["server_id"], name: "index_server_boosters_on_server_id"
    t.index ["user_id"], name: "index_server_boosters_on_user_id"
  end

  create_table "server_categories", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.text "communication_options"
    t.text "tracking_options"
    t.text "infraction_options"
  end

  create_table "server_groups", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "slug"
    t.text "description"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text "data"
    t.string "icon"
  end

  create_table "servers", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "host"
    t.integer "port"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "permissible"
    t.boolean "auto_deploy"
    t.string "path"
    t.string "screen_session"
    t.integer "server_group_id"
    t.integer "server_category_id"
  end

  create_table "sessions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "duration", default: 0
    t.string "ip", limit: 36
    t.datetime "created_at"
    t.integer "server_id"
    t.datetime "updated_at"
    t.boolean "is_active"
    t.boolean "graceful"
    t.index ["ip"], name: "ip"
    t.index ["server_id"], name: "index_sessions_on_server_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "settings", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "key"
    t.string "value"
  end

  create_table "subscriptions", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.integer "discussion_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["user_id"], name: "user_id"
  end

  create_table "team_members", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "role"
    t.datetime "created_at"
    t.integer "team_id"
    t.integer "accepted", default: 0
    t.datetime "accepted_at"
    t.index ["team_id"], name: "team_id"
    t.index ["user_id"], name: "user_id"
  end

  create_table "teams", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci CHECKSUM=1 DELAY_KEY_WRITE=1 ROW_FORMAT=DYNAMIC" do |t|
    t.string "title"
    t.string "tag"
    t.string "tagline"
    t.text "about"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "teamspeak_users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id", null: false
    t.integer "client_id", null: false
  end

  create_table "tournaments", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "name"
    t.string "slug", limit: 64
    t.text "about"
    t.datetime "open_at"
    t.datetime "close_at"
    t.datetime "created_at"
    t.integer "header"
    t.integer "min"
    t.integer "max"
    t.boolean "allow_loners"
  end

  create_table "user_details", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "email"
    t.integer "email_status", default: 0
    t.string "avatar", limit: 16
    t.text "about", limit: 16777215
    t.string "cover_art", limit: 64
    t.string "interests"
    t.string "gender", limit: 8
    t.string "skype", limit: 32
    t.string "twitter", limit: 16
    t.string "facebook", limit: 50
    t.string "twitch", limit: 26
    t.string "steam", limit: 32
    t.string "github", limit: 40
    t.string "discord"
    t.string "custom_badge_icon"
    t.string "custom_badge_color"
    t.string "instagram", limit: 32
    t.index ["user_id"], name: "user_id"
  end

  create_table "usernames", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.integer "user_id"
    t.string "username", limit: 16
    t.datetime "created_at"
    t.index ["user_id"], name: "user_id"
    t.index ["username"], name: "username"
  end

  create_table "users", id: :integer, force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.string "username", limit: 16
    t.string "uuid", limit: 36
    t.string "locale", limit: 8
    t.string "password"
    t.string "tracker"
    t.integer "mc_version"
    t.datetime "created_at"
    t.string "password_secure"
    t.string "verify_key"
    t.boolean "verify_key_success"
    t.bigint "discord_id"
    t.string "api_key"
    t.index ["api_key"], name: "index_users_on_api_key"
    t.index ["username"], name: "username"
    t.index ["uuid"], name: "uuid"
  end

  create_table "votes", force: :cascade, options: "ENGINE=InnoDB DEFAULT CHARSET=utf8 COLLATE=utf8_unicode_ci" do |t|
    t.bigint "user_id"
    t.string "service"
    t.datetime "cast_at"
    t.index ["user_id"], name: "index_votes_on_user_id"
  end

end
