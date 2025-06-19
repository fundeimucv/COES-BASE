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

ActiveRecord::Schema[7.0].define(version: 2025_06_18_145452) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "academic_processes", force: :cascade do |t|
    t.bigint "school_id", null: false
    t.bigint "period_id", null: false
    t.integer "max_credits"
    t.integer "max_subjects"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "modality", default: 0, null: false
    t.bigint "process_before_id"
    t.string "name"
    t.float "registration_amount", default: 0.0
    t.boolean "active", default: false, null: false
    t.boolean "enroll", default: false, null: false
    t.boolean "post_qualification", default: false, null: false
    t.boolean "payments_active", default: false, null: false
    t.float "registration_amount_new", default: 0.0
    t.float "registration_amount_restart", default: 0.0
    t.index ["period_id"], name: "index_academic_processes_on_period_id"
    t.index ["process_before_id"], name: "index_academic_processes_on_process_before_id"
    t.index ["school_id"], name: "index_academic_processes_on_school_id"
  end

  create_table "academic_records", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.bigint "enroll_academic_process_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "status", default: 0
    t.index ["enroll_academic_process_id"], name: "index_academic_records_on_enroll_academic_process_id"
    t.index ["section_id"], name: "index_academic_records_on_section_id"
  end

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.string "state"
    t.string "municipality"
    t.string "city"
    t.string "sector"
    t.string "street"
    t.integer "house_type"
    t.string "house_name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["student_id"], name: "index_addresses_on_student_id"
  end

  create_table "adjuntoblobs", id: :bigint, default: nil, force: :cascade do |t|
    t.string "key", limit: 255, null: false
    t.string "filename", limit: 255, null: false
    t.string "content_type", limit: 255
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
  end

  create_table "adjuntos", id: :bigint, default: nil, force: :cascade do |t|
    t.string "name", limit: 255, null: false
    t.string "record_type", limit: 255, null: false
    t.bigint "record_id", null: false
    t.bigint "adjuntoblob_id", null: false
    t.datetime "created_at", precision: nil, null: false
  end

  create_table "administradores", primary_key: "usuario_id", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.integer "rol", null: false
    t.string "departamento_id", limit: 255
    t.string "escuela_id", limit: 255
    t.bigint "perfil_id"
  end

  create_table "admins", primary_key: "user_id", force: :cascade do |t|
    t.integer "role"
    t.string "env_authorizable_type", default: "Faculty"
    t.bigint "env_authorizable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "profile_id"
    t.index ["env_authorizable_type", "env_authorizable_id"], name: "index_admins_on_env_authorizable"
    t.index ["profile_id"], name: "index_admins_on_profile_id"
    t.index ["user_id"], name: "index_admins_on_user_id"
  end

  create_table "admission_types", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "code"
  end

  create_table "area_authorizables", force: :cascade do |t|
    t.string "name", null: false
    t.string "description"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "areas", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "school_id"
    t.index ["school_id"], name: "index_areas_on_school_id"
  end

  create_table "areas_departaments", id: false, force: :cascade do |t|
    t.bigint "area_id", null: false
    t.bigint "departament_id", null: false
    t.index ["area_id", "departament_id"], name: "index_areas_departaments_on_area_id_and_departament_id"
    t.index ["departament_id", "area_id"], name: "index_areas_departaments_on_departament_id_and_area_id"
  end

  create_table "asignaturas", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.integer "anno"
    t.integer "orden"
    t.integer "calificacion"
    t.integer "activa", limit: 2
    t.string "departamento_id", limit: 255, null: false
    t.string "catedra_id", limit: 255, null: false
    t.string "tipoasignatura_id", limit: 255, null: false
    t.string "id_uxxi", limit: 255
    t.integer "creditos"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "pci", limit: 2, null: false
    t.integer "forzar_absoluta", limit: 2
  end

  create_table "authorizables", force: :cascade do |t|
    t.bigint "area_authorizable_id", null: false
    t.string "klazz", null: false
    t.string "description"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["area_authorizable_id"], name: "index_authorizables_on_area_authorizable_id"
    t.index ["klazz", "area_authorizable_id"], name: "index_authorizables_on_klazz_and_area_authorizable_id", unique: true
  end

  create_table "authorizeds", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.bigint "authorizable_id", null: false
    t.boolean "can_create", default: false
    t.boolean "can_read", default: false
    t.boolean "can_update", default: false
    t.boolean "can_delete", default: false
    t.boolean "can_import", default: false
    t.boolean "can_export", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id", "authorizable_id"], name: "index_authorizeds_on_admin_id_and_authorizable_id", unique: true
    t.index ["admin_id"], name: "index_authorizeds_on_admin_id"
    t.index ["authorizable_id"], name: "index_authorizeds_on_authorizable_id"
  end

  create_table "bancos", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "nombre", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_bancos_on_id"
  end

  create_table "bank_accounts", force: :cascade do |t|
    t.string "code", null: false
    t.string "holder", null: false
    t.bigint "bank_id", null: false
    t.integer "account_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_id"], name: "index_bank_accounts_on_bank_id"
  end

  create_table "banks", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "billboards", force: :cascade do |t|
    t.boolean "active", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "catedradepartamentos", id: :bigint, default: nil, force: :cascade do |t|
    t.string "departamento_id", limit: 255
    t.string "catedra_id", limit: 255
    t.integer "orden"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "catedras", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.integer "orden"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "combinaciones", id: false, force: :cascade do |t|
    t.bigint "id", null: false
    t.string "estudiante_id", limit: 255
    t.string "periodo_id", limit: 255
    t.string "idioma1_id", limit: 255
    t.string "idioma2_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "courses", force: :cascade do |t|
    t.bigint "academic_process_id", null: false
    t.bigint "subject_id", null: false
    t.boolean "offer_as_pci"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "name"
    t.boolean "offer", default: true
    t.index ["academic_process_id"], name: "index_courses_on_academic_process_id"
    t.index ["subject_id"], name: "index_courses_on_subject_id"
  end

  create_table "delayed_jobs", force: :cascade do |t|
    t.integer "priority", default: 0, null: false
    t.integer "attempts", default: 0, null: false
    t.text "handler", null: false
    t.text "last_error"
    t.datetime "run_at"
    t.datetime "locked_at"
    t.datetime "failed_at"
    t.string "locked_by"
    t.string "queue"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["priority", "run_at"], name: "delayed_jobs_priority"
  end

  create_table "departamentos", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.string "escuela_id", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "departaments", force: :cascade do |t|
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["school_id"], name: "index_departaments_on_school_id"
  end

  create_table "direcciones", primary_key: "estudiante_id", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "estado", limit: 255
    t.string "municipio", limit: 255
    t.string "ciudad", limit: 255
    t.string "sector", limit: 255
    t.string "calle", limit: 255
    t.string "tipo_vivienda", limit: 255
    t.string "nombre_vivienda", limit: 255
  end

  create_table "enroll_academic_processes", force: :cascade do |t|
    t.bigint "grade_id", null: false
    t.bigint "academic_process_id", null: false
    t.integer "enroll_status"
    t.integer "permanence_status"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.float "efficiency", default: 1.0
    t.float "simple_average", default: 0.0
    t.float "weighted_average", default: 0.0
    t.index ["academic_process_id"], name: "index_enroll_academic_processes_on_academic_process_id"
    t.index ["grade_id"], name: "index_enroll_academic_processes_on_grade_id"
  end

  create_table "enrollment_days", force: :cascade do |t|
    t.bigint "academic_process_id", null: false
    t.datetime "start"
    t.integer "total_duration_hours", limit: 2
    t.integer "max_grades", limit: 2
    t.integer "slot_duration_minutes", limit: 2
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "by_before_process", default: true, null: false
    t.index ["academic_process_id"], name: "index_enrollment_days_on_academic_process_id"
  end

  create_table "entity_bank_accounts", force: :cascade do |t|
    t.string "bank_accountable_type", null: false
    t.bigint "bank_accountable_id", null: false
    t.bigint "bank_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_entity_bank_accounts_on_bank_account_id"
    t.index ["bank_accountable_type", "bank_accountable_id"], name: "index_entity_bank_accounts_on_bank_accountable"
  end

  create_table "env_auths", force: :cascade do |t|
    t.bigint "admin_id", null: false
    t.string "env_authorizable_type", default: "School"
    t.bigint "env_authorizable_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["admin_id"], name: "index_env_auths_on_admin_id"
    t.index ["env_authorizable_type", "env_authorizable_id"], name: "index_env_auths_on_env_authorizable"
  end

  create_table "escuelaperiodos", id: :bigint, default: nil, force: :cascade do |t|
    t.string "periodo_id", limit: 255
    t.string "escuela_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "max_creditos"
    t.integer "max_asignaturas"
    t.index ["escuela_id", "periodo_id"], name: "index_escuelaperiodos_on_escuela_id_and_periodo_id", unique: true
    t.index ["escuela_id"], name: "index_escuelaperiodos_on_escuela_id"
    t.index ["periodo_id", "escuela_id"], name: "index_escuelaperiodos_on_periodo_id_and_escuela_id", unique: true
    t.index ["periodo_id"], name: "index_escuelaperiodos_on_periodo_id"
  end

  create_table "escuelas", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "inscripcion_abierta", limit: 2
    t.integer "habilitar_retiro_asignaturas", limit: 2
    t.integer "habilitar_cambio_seccion", limit: 2
    t.string "periodo_inscripcion_id", limit: 255
    t.string "periodo_activo_id", limit: 255
    t.integer "habilitar_dependencias", limit: 2
  end

  create_table "estudiantes", primary_key: "usuario_id", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "tipo_estado_inscripcion_id", limit: 255
    t.integer "activo", limit: 2
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "citahoraria_id"
    t.string "discapacidad", limit: 255
    t.string "titulo_universitario", limit: 255
    t.string "titulo_universidad", limit: 255
    t.string "titulo_anno", limit: 255
    t.index ["citahoraria_id"], name: "index_estudiantes_on_citahoraria_id"
    t.index ["tipo_estado_inscripcion_id"], name: "index_estudiantes_on_tipo_estado_inscripcion_id"
    t.index ["usuario_id"], name: "index_estudiantes_on_usuario_id"
  end

  create_table "faculties", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "short_name"
    t.string "coes_boss_name"
    t.string "contact_email"
  end

  create_table "faculty_bank_accounts", force: :cascade do |t|
    t.bigint "faculty_id", null: false
    t.bigint "bank_account_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["bank_account_id"], name: "index_faculty_bank_accounts_on_bank_account_id"
    t.index ["faculty_id"], name: "index_faculty_bank_accounts_on_faculty_id"
  end

  create_table "general_setups", force: :cascade do |t|
    t.string "clave"
    t.string "valor"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "grades", force: :cascade do |t|
    t.bigint "student_id", null: false
    t.bigint "study_plan_id", null: false
    t.integer "graduate_status"
    t.bigint "admission_type_id", null: false
    t.integer "registration_status"
    t.float "efficiency"
    t.float "weighted_average"
    t.float "simple_average"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "appointment_time"
    t.integer "duration_slot_time"
    t.integer "enrollment_status", default: 0, null: false
    t.bigint "enabled_enroll_process_id"
    t.integer "current_permanence_status", default: 0, null: false
    t.bigint "start_id"
    t.bigint "start_process_id"
    t.bigint "language1_id"
    t.bigint "language2_id"
    t.integer "region", default: 0
    t.integer "admission_year"
    t.index ["admission_type_id"], name: "index_grades_on_admission_type_id"
    t.index ["enabled_enroll_process_id"], name: "index_grades_on_enabled_enroll_process_id"
    t.index ["start_id"], name: "index_grades_on_start_id"
    t.index ["start_process_id"], name: "index_grades_on_start_process_id"
    t.index ["student_id", "study_plan_id"], name: "index_grades_on_student_id_and_study_plan_id", unique: true
    t.index ["student_id"], name: "index_grades_on_student_id"
    t.index ["study_plan_id"], name: "index_grades_on_study_plan_id"
  end

  create_table "grados", id: :bigint, default: nil, force: :cascade do |t|
    t.string "escuela_id", limit: 255
    t.string "estudiante_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "estado", null: false
    t.string "culminacion_periodo_id", limit: 255
    t.integer "tipo_ingreso", null: false
    t.integer "inscrito_ucv", limit: 2
    t.integer "estado_inscripcion", null: false
    t.string "plan_id", limit: 255
    t.string "iniciado_periodo_id", limit: 255
    t.bigint "reportepago_id"
    t.string "autorizar_inscripcion_en_periodo_id", limit: 255
    t.integer "region", null: false
    t.decimal "eficiencia", precision: 4, scale: 2, null: false
    t.decimal "promedio_simple", precision: 4, scale: 2, null: false
    t.decimal "promedio_ponderado", precision: 4, scale: 2, null: false
    t.datetime "citahoraria", precision: nil
    t.integer "duracion_franja_horaria"
    t.integer "reglamento", null: false
  end

  create_table "group_tutorials", force: :cascade do |t|
    t.string "name_group"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "historialplanes", id: :bigint, default: nil, force: :cascade do |t|
    t.string "estudiante_id", limit: 255
    t.string "periodo_id", limit: 255
    t.string "plan_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "escuela_id", limit: 255
    t.bigint "grado_id"
    t.index ["escuela_id"], name: "index_historialplanes_on_escuela_id"
    t.index ["estudiante_id", "escuela_id", "periodo_id", "plan_id"], name: "unique_historial", unique: true
    t.index ["estudiante_id", "periodo_id"], name: "index_unique", unique: true
    t.index ["estudiante_id"], name: "index_historialplanes_on_estudiante_id"
    t.index ["grado_id"], name: "fk_rails_d7a1d63156"
    t.index ["periodo_id"], name: "index_historialplanes_on_periodo_id"
    t.index ["plan_id"], name: "index_historialplanes_on_plan_id"
  end

  create_table "inscripcionescuelaperiodos", id: :bigint, default: nil, force: :cascade do |t|
    t.string "estudiante_id", limit: 255, null: false
    t.bigint "escuelaperiodo_id", null: false
    t.string "tipo_estado_inscripcion_id", limit: 255
    t.bigint "reportepago_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "grado_id"
  end

  create_table "inscripcionsecciones", id: :bigint, default: nil, force: :cascade do |t|
    t.bigint "seccion_id"
    t.string "estudiante_id", limit: 255
    t.string "tipo_estado_calificacion_id", limit: 255
    t.string "tipo_estado_inscripcion_id", limit: 255
    t.string "tipoasignatura_id", limit: 255
    t.float "primera_calificacion"
    t.float "segunda_calificacion"
    t.float "tercera_calificacion"
    t.float "calificacion_final"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.float "calificacion_posterior"
    t.integer "estado", null: false
    t.string "tipo_calificacion_id", limit: 255
    t.string "pci_escuela_id", limit: 255
    t.string "escuela_id", limit: 255
    t.integer "pci", limit: 2
    t.bigint "inscripcionescuelaperiodo_id"
    t.bigint "grado_id"
    t.index ["escuela_id"], name: "index_inscripcionsecciones_on_escuela_id"
    t.index ["estudiante_id", "seccion_id"], name: "index_inscripcionsecciones_on_estudiante_id_and_seccion_id", unique: true
    t.index ["estudiante_id"], name: "index_inscripcionsecciones_on_estudiante_id"
    t.index ["grado_id"], name: "fk_rails_d28b12f260"
    t.index ["inscripcionescuelaperiodo_id"], name: "index_inscripcionsecciones_on_inscripcionescuelaperiodo_id"
    t.index ["pci_escuela_id"], name: "fk_rails_24a264013f"
    t.index ["seccion_id", "estudiante_id"], name: "index_inscripcionsecciones_on_seccion_id_and_estudiante_id", unique: true
    t.index ["seccion_id"], name: "index_inscripcionsecciones_on_seccion_id"
    t.index ["tipo_calificacion_id"], name: "fk_rails_d92b783c84"
    t.index ["tipo_estado_calificacion_id"], name: "index_inscripcionsecciones_on_tipo_estado_calificacion_id"
    t.index ["tipo_estado_inscripcion_id"], name: "index_inscripcionsecciones_on_tipo_estado_inscripcion_id"
    t.index ["tipoasignatura_id"], name: "index_inscripcionsecciones_on_tipoasignatura_id"
  end

  create_table "languages", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name"], name: "index_languages_on_name", unique: true
  end

  create_table "mentions", force: :cascade do |t|
    t.string "name"
    t.bigint "study_plan_id", null: false
    t.integer "total_required_subjects", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_plan_id"], name: "index_mentions_on_study_plan_id"
  end

  create_table "mentions_subjects", id: false, force: :cascade do |t|
    t.bigint "mention_id", null: false
    t.bigint "subject_id", null: false
    t.index ["mention_id", "subject_id"], name: "index_mentions_subjects_on_mention_id_and_subject_id", unique: true
    t.index ["mention_id"], name: "index_mentions_subjects_on_mention_id"
    t.index ["subject_id"], name: "index_mentions_subjects_on_subject_id"
  end

  create_table "partial_qualifications", force: :cascade do |t|
    t.decimal "value", precision: 4, scale: 2
    t.integer "partial", default: 1, null: false
    t.bigint "academic_record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["academic_record_id"], name: "index_partial_qualifications_on_academic_record_id"
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
    t.bigint "receiving_bank_account_id"
    t.string "owner_account_name"
    t.string "owner_account_ci"
    t.integer "status", default: 0, null: false
    t.bigint "school_id"
    t.bigint "user_id"
    t.index ["origin_bank_id"], name: "index_payment_reports_on_origin_bank_id"
    t.index ["payable_type", "payable_id"], name: "index_payment_reports_on_payable"
    t.index ["receiving_bank_account_id"], name: "index_payment_reports_on_receiving_bank_account_id"
    t.index ["school_id"], name: "index_payment_reports_on_school_id"
    t.index ["user_id"], name: "index_payment_reports_on_user_id"
  end

  create_table "period_types", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "periodos", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.date "inicia"
    t.date "culmina"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "tipo", null: false
    t.index ["id"], name: "index_periodos_on_id"
  end

  create_table "periods", force: :cascade do |t|
    t.integer "year", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "period_type_id"
    t.string "name"
    t.index ["period_type_id"], name: "index_periods_on_period_type_id"
  end

  create_table "planes", id: false, force: :cascade do |t|
    t.string "id", limit: 255, null: false
    t.string "descripcion", limit: 255
    t.string "escuela_id", limit: 255, null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "creditos"
  end

  create_table "profesores", id: false, force: :cascade do |t|
    t.string "usuario_id", limit: 255, null: false
    t.string "departamento_id", limit: 255
  end

  create_table "profiles", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "programaciones", id: false, force: :cascade do |t|
    t.string "asignatura_id", limit: 255
    t.string "periodo_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "pci", limit: 2, null: false
    t.index ["asignatura_id", "periodo_id"], name: "index_programaciones_on_asignatura_id_and_periodo_id", unique: true
    t.index ["asignatura_id"], name: "index_programaciones_on_asignatura_id"
    t.index ["periodo_id", "asignatura_id"], name: "index_programaciones_on_periodo_id_and_asignatura_id", unique: true
    t.index ["periodo_id"], name: "index_programaciones_on_periodo_id"
  end

  create_table "qualifications", force: :cascade do |t|
    t.bigint "academic_record_id", null: false
    t.integer "value", null: false
    t.integer "type_q", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "definitive", default: true, null: false
    t.index ["academic_record_id"], name: "index_qualifications_on_academic_record_id"
  end

  create_table "reportepagos", id: :bigint, default: nil, force: :cascade do |t|
    t.string "numero", limit: 255
    t.float "monto"
    t.integer "tipo_transaccion"
    t.date "fecha_transaccion"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.string "banco_origen_id", limit: 255
  end

  create_table "requirement_by_levels", force: :cascade do |t|
    t.integer "level"
    t.bigint "study_plan_id", null: false
    t.bigint "subject_type_id", null: false
    t.integer "required_subjects"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_plan_id", "level", "subject_type_id"], name: "study_plan_level_subject_type_unique", unique: true
    t.index ["study_plan_id"], name: "index_requirement_by_levels_on_study_plan_id"
    t.index ["subject_type_id"], name: "index_requirement_by_levels_on_subject_type_id"
  end

  create_table "requirement_by_subject_types", force: :cascade do |t|
    t.bigint "study_plan_id", null: false
    t.bigint "subject_type_id", null: false
    t.integer "required_credits", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["study_plan_id"], name: "index_requirement_by_subject_types_on_study_plan_id"
    t.index ["subject_type_id"], name: "index_requirement_by_subject_types_on_subject_type_id"
  end

  create_table "schedules", force: :cascade do |t|
    t.bigint "section_id", null: false
    t.integer "day"
    t.time "starttime"
    t.time "endtime"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_schedules_on_section_id"
  end

  create_table "schools", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.integer "type_entity", default: 0, null: false
    t.boolean "enable_subject_retreat"
    t.boolean "enable_change_course"
    t.boolean "enable_dependents", default: false, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "faculty_id"
    t.bigint "active_process_id"
    t.bigint "enroll_process_id"
    t.boolean "enable_enroll_payment_report", default: false, null: false
    t.string "short_name"
    t.boolean "enable_by_level", default: false
    t.boolean "have_partial_qualification", default: false, null: false
    t.boolean "have_language_combination", default: false, null: false
    t.index ["active_process_id"], name: "index_schools_on_active_process_id"
    t.index ["enroll_process_id"], name: "index_schools_on_enroll_process_id"
    t.index ["faculty_id"], name: "index_schools_on_faculty_id"
  end

  create_table "seccion_profesores_secundarios", id: :bigint, default: nil, force: :cascade do |t|
    t.string "profesor_id", limit: 255
    t.bigint "seccion_id"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "secciones", id: :bigint, default: nil, force: :cascade do |t|
    t.string "numero", limit: 255
    t.string "asignatura_id", limit: 255
    t.string "periodo_id", limit: 255
    t.string "profesor_id", limit: 255
    t.integer "calificada", limit: 2
    t.integer "capacidad"
    t.string "tipo_seccion_id", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "abierta", limit: 2
    t.index ["asignatura_id"], name: "index_secciones_on_asignatura_id"
    t.index ["numero", "periodo_id", "asignatura_id"], name: "index_secciones_on_numero_and_periodo_id_and_asignatura_id", unique: true
    t.index ["periodo_id"], name: "index_secciones_on_periodo_id"
    t.index ["profesor_id"], name: "index_secciones_on_profesor_id"
    t.index ["tipo_seccion_id"], name: "index_secciones_on_tipo_seccion_id"
  end

  create_table "sections", force: :cascade do |t|
    t.string "code"
    t.integer "capacity"
    t.bigint "course_id", null: false
    t.boolean "qualified", default: false, null: false
    t.integer "modality"
    t.boolean "enabled"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "teacher_id"
    t.string "classroom"
    t.index ["code", "course_id"], name: "index_sections_on_code_and_course_id", unique: true
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
    t.string "grade_title"
    t.string "grade_university"
    t.integer "graduate_year"
    t.integer "sede", default: 0, null: false
    t.index ["user_id"], name: "index_students_on_user_id"
  end

  create_table "study_plans", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.bigint "school_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "total_credits", default: 0
    t.integer "modality", default: 0, null: false
    t.integer "levels", default: 10, null: false
    t.integer "structure", default: 0, null: false
    t.index ["school_id"], name: "index_study_plans_on_school_id"
  end

  create_table "subject_links", force: :cascade do |t|
    t.bigint "prelate_subject_id", null: false
    t.bigint "depend_subject_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["depend_subject_id"], name: "index_subject_links_on_depend_subject_id"
    t.index ["prelate_subject_id", "depend_subject_id"], name: "link_parent_depend", unique: true
    t.index ["prelate_subject_id"], name: "index_subject_links_on_prelate_subject_id"
  end

  create_table "subject_types", force: :cascade do |t|
    t.string "name"
    t.string "code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "subjects", force: :cascade do |t|
    t.string "code", null: false
    t.string "name", null: false
    t.boolean "active", default: true
    t.integer "unit_credits", default: 5, null: false
    t.integer "ordinal", default: 0, null: false
    t.integer "qualification_type"
    t.bigint "area_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "force_absolute", default: false
    t.bigint "subject_type_id", null: false
    t.bigint "school_id"
    t.bigint "departament_id"
    t.index ["area_id"], name: "index_subjects_on_area_id"
    t.index ["departament_id"], name: "index_subjects_on_departament_id"
    t.index ["school_id"], name: "index_subjects_on_school_id"
    t.index ["subject_type_id"], name: "index_subjects_on_subject_type_id"
  end

  create_table "teachers", primary_key: "user_id", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "departament_id"
    t.index ["departament_id"], name: "index_teachers_on_departament_id"
    t.index ["user_id"], name: "index_teachers_on_user_id"
  end

  create_table "timeblocks", force: :cascade do |t|
    t.integer "day", default: 0
    t.time "start_time", default: "2000-01-01 07:00:00"
    t.time "end_time", default: "2000-01-01 09:00:00"
    t.integer "modality", default: 0
    t.string "classroom"
    t.bigint "teacher_id"
    t.bigint "timetable_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["teacher_id"], name: "index_timeblocks_on_teacher_id"
    t.index ["timetable_id", "day", "end_time"], name: "index_timeblocks_on_timetable_and_day_and_end_time", unique: true
    t.index ["timetable_id", "day", "start_time"], name: "index_timeblocks_on_timetable_and_day_and_start_time", unique: true
    t.index ["timetable_id"], name: "index_timeblocks_on_timetable_id"
  end

  create_table "timetables", force: :cascade do |t|
    t.string "name"
    t.string "color"
    t.bigint "section_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["section_id"], name: "index_timetables_on_section_id"
  end

  create_table "tipo_calificaciones", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_tipo_calificaciones_on_id"
  end

  create_table "tipo_estado_calificaciones", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["id"], name: "index_tipo_estado_calificaciones_on_id"
  end

  create_table "tipo_estado_inscripciones", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tipo_secciones", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tipoasignaturas", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "descripcion", limit: 255
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
  end

  create_table "tutorials", force: :cascade do |t|
    t.string "name_function"
    t.bigint "group_tutorial_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["group_tutorial_id"], name: "index_tutorials_on_group_tutorial_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "ci", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "first_name"
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
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.boolean "updated_password", default: false, null: false
    t.string "location_number_phone"
    t.index ["ci"], name: "index_users_on_ci", unique: true
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  create_table "usuarios", primary_key: "ci", id: { type: :string, limit: 255 }, force: :cascade do |t|
    t.string "nombres", limit: 255
    t.string "apellidos", limit: 255
    t.string "email", limit: 255
    t.string "telefono_habitacion", limit: 255
    t.string "telefono_movil", limit: 255
    t.string "password", limit: 255
    t.integer "sexo", null: false
    t.datetime "created_at", precision: nil, null: false
    t.datetime "updated_at", precision: nil, null: false
    t.integer "nacionalidad"
    t.integer "estado_civil"
    t.date "fecha_nacimiento"
    t.string "pais_nacimiento", limit: 255
    t.string "ciudad_nacimiento", limit: 255
  end

  create_table "versions", force: :cascade do |t|
    t.string "item_type", null: false
    t.bigint "item_id", null: false
    t.string "event", null: false
    t.string "whodunnit"
    t.text "object"
    t.datetime "created_at"
    t.text "object_changes"
    t.index ["item_type", "item_id"], name: "index_versions_on_item_type_and_item_id"
  end

  add_foreign_key "academic_processes", "academic_processes", column: "process_before_id"
  add_foreign_key "academic_processes", "periods"
  add_foreign_key "academic_processes", "schools"
  add_foreign_key "academic_records", "enroll_academic_processes"
  add_foreign_key "academic_records", "sections"
  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "students", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "admins", "users"
  add_foreign_key "areas", "schools"
  add_foreign_key "authorizables", "area_authorizables"
  add_foreign_key "authorizeds", "admins", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "authorizeds", "authorizables", on_update: :cascade, on_delete: :cascade
  add_foreign_key "bank_accounts", "banks"
  add_foreign_key "courses", "academic_processes"
  add_foreign_key "courses", "subjects"
  add_foreign_key "departaments", "schools"
  add_foreign_key "enroll_academic_processes", "academic_processes"
  add_foreign_key "enroll_academic_processes", "grades"
  add_foreign_key "enrollment_days", "academic_processes"
  add_foreign_key "env_auths", "admins", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "escuelaperiodos", "escuelas", name: "escuelaperiodos_escuela_id_fkey"
  add_foreign_key "grades", "academic_processes", column: "enabled_enroll_process_id"
  add_foreign_key "grades", "academic_processes", column: "start_process_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "grades", "admission_types"
  add_foreign_key "grades", "languages", column: "language1_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "grades", "languages", column: "language2_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "grades", "students", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "grades", "study_plans"
  add_foreign_key "mentions", "study_plans"
  add_foreign_key "mentions_subjects", "mentions"
  add_foreign_key "mentions_subjects", "subjects"
  add_foreign_key "partial_qualifications", "academic_records"
  add_foreign_key "payment_reports", "bank_accounts", column: "receiving_bank_account_id", on_update: :cascade, on_delete: :nullify
  add_foreign_key "payment_reports", "banks", column: "origin_bank_id"
  add_foreign_key "payment_reports", "schools"
  add_foreign_key "payment_reports", "users"
  add_foreign_key "qualifications", "academic_records"
  add_foreign_key "requirement_by_levels", "study_plans"
  add_foreign_key "requirement_by_levels", "subject_types"
  add_foreign_key "requirement_by_subject_types", "study_plans"
  add_foreign_key "requirement_by_subject_types", "subject_types"
  add_foreign_key "schedules", "sections"
  add_foreign_key "schools", "academic_processes", column: "active_process_id"
  add_foreign_key "schools", "academic_processes", column: "enroll_process_id"
  add_foreign_key "secciones", "tipo_secciones", column: "tipo_seccion_id", name: "secciones_tipo_seccion_id_fkey"
  add_foreign_key "sections", "courses"
  add_foreign_key "sections", "teachers", primary_key: "user_id", on_update: :cascade, on_delete: :cascade
  add_foreign_key "sections_teachers", "sections"
  add_foreign_key "sections_teachers", "teachers", primary_key: "user_id"
  add_foreign_key "students", "users"
  add_foreign_key "study_plans", "schools"
  add_foreign_key "subject_links", "subjects", column: "depend_subject_id"
  add_foreign_key "subject_links", "subjects", column: "prelate_subject_id"
  add_foreign_key "subjects", "areas"
  add_foreign_key "subjects", "departaments"
  add_foreign_key "subjects", "schools"
  add_foreign_key "subjects", "subject_types"
  add_foreign_key "teachers", "departaments"
  add_foreign_key "teachers", "users"
  add_foreign_key "timeblocks", "timetables"
  add_foreign_key "timetables", "sections"
  add_foreign_key "tutorials", "group_tutorials"
end
