class Sites::Impl::Century < Sites::AbstractSite
  BASE_URL = 'https://www.21vek.by/'.freeze

  def initialize
    @category_names = {
        refrigerators: 'refrigerators',
        teapots: 'teapots',
        coffee_machines: 'coffee_machines',
        vacuum: 'vacuum',
        tv: 'tv',
        video_cameras: 'video_cameras',
        cameras: 'cameras'
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
      categories << Category.new(BASE_URL + c_name, db_name)
    end

    categories.each do |category|
      category.load_pages("a.cr-paging_link[rel='next']")
      category.pages.each { |page| page.load_links('a.result__link') }
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
                from_link(link, category.db_name)
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

        if (price = doc.css("span[itemprop='price']").first)
          attributes[:price] = price.text.gsub(/\s+/, '').gsub(/,/, '.').to_f
        end

        attributes[:status] = attributes[:price].present? ? true : false

        matched_data = doc.css('script:contains("vendor")').first.content.match(/vendor.+,/)

        if matched_data
          brand_name = matched_data.to_s.split(':').last.match(/[a-zA-Zа-яА-Я-]+/).to_s.upcase
        end

        return if brand_name.blank?

        if (model = doc.css('h1[itemprop="name"]').first)
          attributes[:model] = model.text.upcase.gsub(/.+#{brand_name}/, '')
        end

        create_product(attributes, category_name, brand_name, link)
      end
    end
  end
end
