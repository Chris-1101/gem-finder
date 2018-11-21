class Property < ApplicationRecord
  has_many :trackings

  # Cloudinary
  mount_uploader :photo, PhotoUploader

  # Mapbox
  geocoded_by :location
  after_validation :geocode, if: :will_save_change_to_location?
end
