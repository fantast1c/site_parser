module Sites::Categorized
  class Category
    attr_reader :pages, :db_name, :url, :doc

    def initialize(url, db_name)
      @url = url
      @db_name = db_name
      @doc = Sites::Utils::Nokogiri.document(@url)
    end

    def load_pages(next_link_selector, base_url = nil)
      @pages ||= Array.new
      @pages << Page.new(@doc)

      next_link = @doc.css(next_link_selector).first

      if next_link.present?
        next_url = base_url.present? ? base_url + next_link[:href] : next_link[:href]
        @doc = Sites::Utils::Nokogiri.document(next_url)
        load_pages(next_link_selector, base_url)
      end

      self
    end
  end

  class Page
    attr_reader :links

    def initialize(doc)
      @doc = doc
      @links = []
    end

    def load_links(link_selector)
      @links = @doc.css(link_selector).map do |link|
        link[:href]
      end

      self
    end
  end
end