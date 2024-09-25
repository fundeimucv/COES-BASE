class AddByBeforeProcessToEnrollmentDay < ActiveRecord::Migration[7.0]
  def change
    add_column :enrollment_days, :by_before_process, :boolean, default: true, null: false
  end
end
