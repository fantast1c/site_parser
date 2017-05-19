class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable, :validatable

  devise :omniauthable, omniauth_providers: [:google_oauth2, :facebook]

  # just a simple solution for the case with such relation
  has_and_belongs_to_many :favorite_products, class_name: 'Product'

  def self.from_omniauth(access_token)
    data = access_token.info
    user = User.where(:email => data['email']).first

    unless user
      user = User.create(email: data['email'], password: Devise.friendly_token[0, 20])
    end

    user
  end

  def stop_notifying
    favorite_products.clear unless favorite_products.empty?
  end
end
