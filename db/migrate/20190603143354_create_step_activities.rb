class CreateStepActivities < ActiveRecord::Migration[5.2]
  def change
    create_table :step_activities do |t|
      t.references :step, foreign_key: true
      t.references :activity, foreign_key: true

      t.timestamps
    end
  end
end
