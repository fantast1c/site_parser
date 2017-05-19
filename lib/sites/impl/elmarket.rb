class Sites::Impl::Elmarket < Sites::AbstractSite
  CATALOG_URL = 'https://www.elmarket.by/catalog/'.freeze
  BASE_URL = 'https://www.elmarket.by'.freeze

  def initialize
    @category_names = {
        refrigerators: 'holodilniki',
        teapots: 'elektricheskie_chainiki',
        coffee_machines: 'kofevarki_i_kofemashiny',
        vacuum: 'pylesosy',
        tv: 'televizory',
        video_cameras: 'videokamery',
        cameras: 'cifrovye_fotokamery'
    }

    @pool = Sites::ThreadPool.instance
  end

  def load_products
    @pool.post { real_loading }
  end

  def rescuer
    Proc.new { |reason| puts "REJECTED: #{reason}" }
  end

  protected

  def real_loading
    categories = []

    @category_names.each do |db_name, c_name|
      categories << Category.new(CATALOG_URL + c_name, db_name)
    end

    categories.each do |category|
      category.load_pages('a.blog-page-next', BASE_URL)
      category.pages.each { |page| page.load_links('a.title-cat') }
    end

    ProductService.from_categories(categories)

    true
  end

  class ProductService < Sites::AbstractSite::AbstractService
    class << self
      def from_categories(categories)
        categories.each do |category|
          category.pages.each do |page|
            page.links.each do |link|
              begin
                from_link(BASE_URL + link, category.db_name)
              rescue Exception => exc
                Rails.logger.error(exc.backtrace)
                puts exc.backtrace
              end
            end
          end
        end
      end

      protected

      def from_link(link, category_name)
        attributes = {}
        doc = Sites::Utils::Nokogiri.document(link)

        if (product_details = doc.css('#detail-element').first)
          product_id = product_details['data-element-code']
          json = doc.css("#json-product-#{product_id}").first.text
          parsed_json = JSON.parse(json)
          attributes[:price] = parsed_json['price'].gsub(/\s+/, '').gsub(/,/, '.').to_f
          attributes[:status] = parsed_json['status']
          brand_name = parsed_json['brand'].upcase
          return if brand_name.blank?

          if (model = doc.css('.header-title h1').first)
            attributes[:model] = model.text.upcase.gsub(/.+#{brand_name}/, '')
          end

          create_product(attributes, category_name, brand_name, link)
        end
      end
    end
  end
end
