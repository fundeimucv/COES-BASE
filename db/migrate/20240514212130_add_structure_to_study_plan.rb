class AddStructureToStudyPlan < ActiveRecord::Migration[7.0]
  def change
    add_column :study_plans, :structure, :integer, default: 0, null: false    
  end
end
