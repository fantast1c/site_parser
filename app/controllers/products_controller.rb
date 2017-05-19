class ProductsController < ApplicationController
  def favorite
    @product = Product.find(params[:product_id])

    if current_user.favorite_products.exists?(@product.id)
      flash.now[:info] = I18n.t('already_favorite')
    else
      flash.now[:info] = I18n.t('favorite_added')
      current_user.favorite_products << @product
    end

    render 'shared/flash'
  end

  def stop_notifying
    current_user.stop_notifying
    flash.now[:info] = I18n.t('notification_stopped')

    render 'shared/flash'
  end
end
