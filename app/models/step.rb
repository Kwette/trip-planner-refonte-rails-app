class Step < ApplicationRecord
  belongs_to :city
  belongs_to :trip
  has_many :step_activities, dependent: :destroy
  has_many :activities, through: :step_activities
end
