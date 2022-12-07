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

ActiveRecord::Schema[7.0].define(version: 2022_12_07_201132) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_processes", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "period_id", null: false
    t.integer "max_credit"
    t.integer "max_subjects"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["period_id"], name: "index_academic_processes_on_period_id"
    t.index ["school_id"], name: "index_academic_processes_on_school_id"
  end

  create_table "admins", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.integer "role"
    t.string "env_authorizable_type", default: "Faculty"
    t.bigint "env_authorizable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["env_authorizable_type", "env_authorizable_id"], name: "index_admins_on_env_authorizable"
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "admission_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_admission_types_on_school_id"
  end

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "school_id", null: false
    t.bigint "area_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_areas_on_area_id"
    t.index ["school_id"], name: "index_areas_on_school_id"
  end

  create_table "banks", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "academic_process_id", null: false
    t.bigint "subject_id", null: false
    t.boolean "offer_as_pci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_process_id"], name: "index_courses_on_academic_process_id"
    t.index ["subject_id"], name: "index_courses_on_subject_id"
  end

  create_table "enroll_academic_procces", force: :cascade do |t|
    t.bigint "grade_id", null: false
    t.bigint "academic_process_id", null: false
    t.integer "enroll_status"
    t.integer "permanence_state"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_process_id"], name: "index_enroll_academic_procces_on_academic_process_id"
    t.index ["grade_id"], name: "index_enroll_academic_procces_on_grade_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "study_plan_id", null: false
    t.integer "graduate_status"
    t.integer "enroll_state"
    t.bigint "admission_type_id", null: false
    t.integer "registration_status"
    t.float "efficiency"
    t.float "weighted_average"
    t.float "simple_average"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admission_type_id"], name: "index_grades_on_admission_type_id"
    t.index ["student_id", "study_plan_id"], name: "index_grades_on_student_id_and_study_plan_id", unique: true
    t.index ["student_id"], name: "index_grades_on_student_id"
    t.index ["study_plan_id"], name: "index_grades_on_study_plan_id"
  end

  create_table "payment_reports", force: :cascade do |t|
    t.float "amount"
    t.string "transaction_id"
    t.integer "transaction_type"
    t.date "transaction_date"
    t.bigint "origin_bank_id", null: false
    t.string "payable_type"
    t.bigint "payable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["origin_bank_id"], name: "index_payment_reports_on_origin_bank_id"
    t.index ["payable_type", "payable_id"], name: "index_payment_reports_on_payable"
  end

  create_table "periods", force: :cascade do |t|
    t.integer "ordinal"
    t.integer "year"
    t.integer "modality"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "schools", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.boolean "enable_subject_retreat"
    t.boolean "enable_change_course"
    t.boolean "enable_dependents"
    t.bigint "period_active_id"
    t.bigint "period_enroll_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "faculty_id"
    t.index ["faculty_id"], name: "index_schools_on_faculty_id"
    t.index ["period_active_id"], name: "index_schools_on_period_active_id"
    t.index ["period_enroll_id"], name: "index_schools_on_period_enroll_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "code"
    t.integer "capacity"
    t.bigint "course_id", null: false
    t.bigint "teacher_id", null: false
    t.boolean "qualified"
    t.integer "modality"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["course_id"], name: "index_sections_on_course_id"
    t.index ["teacher_id"], name: "index_sections_on_teacher_id"
  end

  create_table "sections_teachers", id: false, force: :cascade do |t|
    t.bigint "section_id", null: false
    t.bigint "teacher_id", null: false
    t.index ["section_id", "teacher_id"], name: "index_sections_teachers_on_section_id_and_teacher_id", unique: true
  end

  create_table "students", primary_key: "user_id", force: :cascade do |t|
    t.boolean "active", default: true
    t.integer "disability"
    t.integer "nacionality"
    t.integer "marital_status"
    t.string "origin_country"
    t.string "origin_city"
    t.date "birth_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "study_plans", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_study_plans_on_school_id"
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "active", default: true
    t.integer "unit_credits", default: 24, null: false
    t.integer "ordinal", default: 0, null: false
    t.integer "qualification_type"
    t.integer "modality"
    t.bigint "area_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_subjects_on_area_id"
  end

  create_table "teachers", primary_key: "user_id", force: :cascade do |t|
    t.bigint "area_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_id"], name: "index_teachers_on_area_id"
    t.index ["user_id"], name: "index_teachers_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "ci", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name"
    t.string "last_name"
    t.string "number_phone"
    t.integer "sex"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["ci"], name: "index_users_on_ci", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
  end

  add_foreign_key "academic_processes", "periods"
  add_foreign_key "academic_processes", "schools"
  add_foreign_key "admins", "users"
  add_foreign_key "admission_types", "schools"
  add_foreign_key "areas", "areas"
  add_foreign_key "areas", "schools"
  add_foreign_key "courses", "academic_processes"
  add_foreign_key "courses", "subjects"
  add_foreign_key "enroll_academic_procces", "academic_processes"
  add_foreign_key "enroll_academic_procces", "grades"
  add_foreign_key "grades", "admission_types"
  add_foreign_key "grades", "students", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "grades", "study_plans"
  add_foreign_key "payment_reports", "banks", column: "origin_bank_id"
  add_foreign_key "schools", "periods", column: "period_active_id"
  add_foreign_key "schools", "periods", column: "period_enroll_id"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "teachers", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "sections_teachers", "sections"
  add_foreign_key "sections_teachers", "teachers", primary_key: "user_id"
  add_foreign_key "students", "users"
  add_foreign_key "study_plans", "schools"
  add_foreign_key "subjects", "areas"
  add_foreign_key "teachers", "areas"
  add_foreign_key "teachers", "users"
end
