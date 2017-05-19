class Sites::Utils::Nokogiri
  class << self
    def document(url)
      html = RestClient.get(url)
      Nokogiri::HTML(html)
    end

    def ajax(url)
      headless = Headless.new

      headless.start
      browser = Watir::Browser.start(url)
      sleep(1)
      doc = Nokogiri::HTML(browser.html)
      headless.destroy

      doc
    end
  end
end