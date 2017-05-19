class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  # just a simple solution for the case with such relation
  has_and_belongs_to_many :brands

  validates_presence_of :name
end
