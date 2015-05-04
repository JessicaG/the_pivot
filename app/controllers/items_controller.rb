class ItemsController < ApplicationController
  load_and_authorize_resource

  before_action :set_item, only: [:show]
  before_action :item_rating, only: [:index, :show]

  def index
    if params[:search]
      @items = Item.search(params[:search]).order("created_at DESC")
    else
      @items = Item.active
    end
    @categories = Category.all
  end

  def search
    @items = Item.search params[:search]
  end
  
  def show
    @categories = @item.categories
  end

  private

    def set_item
#      @item = Item.find(params[:id])
    end

    def item_rating
#      @reviews = Review.where(item_id: @item.id) || []
#        if !@reviews.empty?
#          @average = @item.average_rating
#        else
#          @average = 0
#        end
    end
end
