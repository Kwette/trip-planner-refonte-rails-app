class AddMisteryToStepActivities < ActiveRecord::Migration[5.2]
  def change
    add_column :step_activities, :mistery, :boolean
  end
end
