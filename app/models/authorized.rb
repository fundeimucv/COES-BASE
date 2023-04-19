class Authorized < ApplicationRecord
  # SCHEMA
  # t.bigint "admin_id", null: false
  # t.string "clazz", null: false
  # t.boolean "can_create", default: false
  # t.boolean "can_read", default: false
  # t.boolean "can_update", default: false
  # t.boolean "can_delete", default: false
  # t.boolean "can_import", default: false
  # t.boolean "can_export", default: false

  belongs_to :admin
end
