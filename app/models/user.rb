class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :trackings
  has_many :properties, through: :trackings
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
end
