class Property < ApplicationRecord
  has_many :trackings
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?
end
