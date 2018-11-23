class Property < ApplicationRecord
  belongs_to :postcode
  has_many :trackings

  # Cloudinary
  mount_uploader :photo, PhotoUploader

  # Mapbox
  geocoded_by :address
  after_validation :geocode, if: :will_save_change_to_address?

end
