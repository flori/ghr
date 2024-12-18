# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2023_11_10_203518) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"

  create_table "github_releases", force: :cascade do |t|
    t.bigint "github_repo_id", null: false
    t.string "url", null: false
    t.string "html_url", null: false
    t.string "name", null: false
    t.string "tag_name", null: false
    t.datetime "published_at", null: false
    t.text "body"
    t.boolean "notify_jira", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["github_repo_id"], name: "index_github_releases_on_github_repo_id"
  end

  create_table "github_repos", force: :cascade do |t|
    t.string "user", null: false
    t.string "repo", null: false
    t.boolean "notify_jira", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "tag_filter", default: "", null: false
    t.boolean "lightweight", default: false, null: false
    t.boolean "import_enabled", default: true, null: false
    t.boolean "jira_enabled", default: true
    t.string "version_requirement", default: [], array: true
    t.index ["user", "repo"], name: "index_github_repos_on_user_and_repo", unique: true
  end
end
