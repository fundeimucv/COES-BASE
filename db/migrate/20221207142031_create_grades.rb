class CreateGrades < ActiveRecord::Migration[7.0]
  def change
    create_table :grades do |t|
      t.references :student, null: false, foreign_key: {primary_key: :user_id, on_delete: :cascade, on_update: :cascade}
      t.references :study_plan, null: false, foreign_key: true
      t.integer :role
      t.integer :enroll_state
      t.integer :admission
      t.integer :normative
      t.boolean :university_registred
      t.float :efficiency
      t.float :weighted_average
      t.float :simple_average
      t.index [:student_id, :study_plan_id], unique: true
      t.timestamps
    end
  end
end
