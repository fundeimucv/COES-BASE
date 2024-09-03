class DeleteSchoolIdToAdmissionType < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :admission_types, :schools
    remove_column :admission_types, :school_id
  end
end
