class Brand < ApplicationRecord
  # just a simple solution for the case with such relation
  has_and_belongs_to_many :categories
  has_many :products, dependent: :destroy

  validates_presence_of :name
end
