class AddRequiredCreditsToStudyPlan < ActiveRecord::Migration[7.0]
  def change
    add_column :study_plans, :required_credits, :integer, null: false, default: "0"
  end
end
