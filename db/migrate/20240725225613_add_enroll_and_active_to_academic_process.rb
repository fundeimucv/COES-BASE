class AddEnrollAndActiveToAcademicProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :academic_processes, :active, :boolean, default: false, null: false
    add_column :academic_processes, :enroll, :boolean, default: false, null: false
    add_column :academic_processes, :post_qualification, :boolean, default: false, null: false
  end
end
