namespace :sites do
  desc 'parses predefined sites'
  task parse_sources: :environment do
    Product.from_source(Sites::Impl::Century.new)
    Product.from_source(Sites::Impl::Imarket.new)
    Product.from_source(Sites::Impl::Elmarket.new)
    Sites::ThreadPool.instance.wait_termination
  end
end
