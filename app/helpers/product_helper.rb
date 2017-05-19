module ProductHelper
  def product_details(product)
    details = product.brand.name + ', ' + product.model

    if product.available?
      details += ', ' + product.price.to_s
    else
      details += ', product is not available'
    end

    if product.available? && product.best?
      details += ' (best price)'
    end

    details += ', ' + link_to(:source, product.source)
    details += ', ' + link_to(:favorite, product_favorite_path(product), remote: true)
    details.html_safe
  end
end
