module Sites
  class AbstractSite
    include Sites::Categorized

    def load_products
      raise 'Not implemented!'
    end

    def rescuer
      raise 'Not implemented!'
    end

    protected

    def real_loading
      raise 'Not implemented!'
    end

    class AbstractService
      class << self
        def from_categories(categories)
          raise 'Not implemented!'
        end

        protected

        def from_link(link, category_name)
          raise 'Not implemented!'
        end

        private

        def create_product(attributes, category_name, brand_name, source)
          attributes[:source] = source
          attributes[:category] = Category.find_or_create_by(name: category_name)
          attributes[:brand] = Brand.find_or_create_by(name: brand_name).tap do |b|
            b.categories << attributes[:category] unless b.categories.exists?(attributes[:category].id)
          end

          product = Product.find_by(attributes.except(:price, :status))

          if product.present? && product.price != attributes[:price]
            product.update(price: attributes[:price], status: attributes[:status])
          else
            Product.create(attributes)
          end
        end
      end
    end
  end
end