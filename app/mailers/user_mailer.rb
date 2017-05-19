class UserMailer < ApplicationMailer
  def price_update_notification(user, product, prev_price)
    mail(
        to: user.email,
        subject: "Product's (#{product.brand.name}, #{product.model}) price was changed",
        body: "price was changed from #{prev_price} to #{product.price}"
    )
  end
end
