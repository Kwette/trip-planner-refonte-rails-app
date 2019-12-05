class City < ApplicationRecord
  has_many :steps
  has_many :trips
  has_many :activities
  geocoded_by :name
  after_validation :geocode, if: :will_save_change_to_name?
end
