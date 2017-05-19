class Sites::Impl::Techno < Sites::AbstractSite
  BASE_URL = 'http://techno.by/'.freeze

  def initialize
    @category_names = {
        refrigerators: 'refrigerators-freezers',
        teapots: 'electric-kettles',
        coffee_machines: 'coffee-makers',
        vacuum: 'vacuum-cleaners',
        tv: 'tvs',
        video_cameras: 'videokamery',
        cameras: 'foto'
    }

    @pool = Sites::ThreadPool.instance
  end

  def load_products
    true
  end

  def rescuer
    Proc.new { |reason| puts "REJECTED: #{reason}" }
  end

  class ProductService < Sites::AbstractSite::AbstractService
    class << self
      def from_categories(categories)
        categories.each do |category|
          category.pages.each do |page|
            page.links.each do |link|
              from_link(link, category.db_name)
            end
          end
        end
      end

      private

      def from_link(link, category_name)
        attributes = {}
        doc = Sites::Utils::Nokogiri.document(link)

        attributes[:price] = doc.css("span[itemprop='price']").first.try(:text)
        attributes[:status] = attributes[:price].present? ? true : false

        matched_data = doc.css('script:contains("vendor")').first.content.match(/vendor.+,/)

        if matched_data
          attributes[:manufacturer] = matched_data.to_s.split(':').last.match(/[a-zA-Z]+/).to_s
        end

        if (model = doc.css('h1[itemprop="name"]').first) && attributes[:manufacturer]
          attributes[:model] = model.text.gsub(/.+#{attributes[:manufacturer]}/, '').strip
        end

        attributes[:source] = link
        attributes[:category] = Category.find_or_create_by(name: category_name)

        Product.find_or_create_by(attributes)
      end
    end
  end
end
