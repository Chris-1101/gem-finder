class User < ApplicationRecord
  # Include default devise modules. Others available are:
  mount_uploader :photo, PhotoUploader
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :trackings, dependent: :destroy
  has_many :properties, through: :trackings
  devise :database_authenticatable, :registerable,
  :recoverable, :rememberable, :validatable

end
