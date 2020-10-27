class User < ApplicationRecord
  has_secure_password
  validates_presence_of :name, :street_address, :city, :state, :zip, :email, :password, :password_confirmation   
  validates :email, uniqueness: true, presence: true
end