module SiteProcessor
  def from_source(site)
    raise "Wrong strategy class #{site.class}, should be subclass of #{Sites::AbstractSite}" unless site.is_a?(Sites::AbstractSite)

    site.load_products
  end
end