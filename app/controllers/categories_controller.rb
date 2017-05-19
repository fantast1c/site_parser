class CategoriesController < ApplicationController
  before_action :authenticate_user!

  def index
    @categories = Category.all
  end

  def show(category_id = params[:id])
    @category = Category.find(category_id)
    @products = @category.products.includes(:brand).order('brands.name', :model, :price)
  end

  def search
    if params[:brand].blank?
      show(params[:category_id])
      return render :show
    end

    @category = Category.find(params[:category_id])
    @brand = Brand.find(params[:brand])
    make_search = params[:from_price].present? && params[:to_price].present?

    if make_search
      @products = @brand.products.price_between(params[:from_price], params[:to_price])
    else
      @products = @brand.products.includes(:brand).order('brands.name', :model, :price)
    end

    render :show
  end
end
