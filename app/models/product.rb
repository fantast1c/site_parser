class Product < ApplicationRecord
  extend SiteProcessor

  belongs_to :category
  belongs_to :brand
  # just a simple solution for the case with such relation
  has_and_belongs_to_many :assigned_users, class_name: 'User'
  scope :same_products, -> (brand, model) { where(brand: brand, model: model).where.not(price: nil) }
  scope :price_between, -> (from, to) { where('price > ? and price < ?', from, to) }
  validates_presence_of :model, :source

  before_create :determine_best
  after_update :notify_assigned_users

  def available?
    if status == '1'
      true
    else
      false
    end
  end

  def best?
    best
  end

  private

  def determine_best
    same_products = self.class.same_products(self.brand, self.model)
    no_similar = same_products.blank?

    if no_similar
      self.best = true
      return true
    end

    prev_best = same_products.min_by(&:price)
    is_best = prev_best.price > self.price if self.price.present?

    if is_best
      prev_best.update(best: false)
      self.best = true
    end
  end

  def notify_assigned_users
    if price_changed?
      assigned_users.each do |user|
        UserMailer.price_update_notification(user, self, price_was).deliver_later
      end
    end
  end
end
