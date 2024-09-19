class AddAmountNewAndRestartToAcademicProcess < ActiveRecord::Migration[7.0]
  def change
    add_column :academic_processes, :registration_amount_new, :float, default: 0
    add_column :academic_processes, :registration_amount_restart, :float, default: 0
  end
end
