class AddReportsToAcademicProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :academic_processes, :payments_active, :boolean, default: false, null: false
  end
end
