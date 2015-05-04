class Item < ActiveRecord::Base
  validates :title, presence: true, uniqueness: true
  validates :description, presence: true
  validates :price, numericality: { greater_than: 0 }
  validates :categories, presence: true
  has_many :line_items
  has_many :orders, through: :line_items
  has_many :reviews
  has_many :vendor_order_items
  has_many :vendor_orders, through: :vendor_order_items
  belongs_to :vendor
  has_many :item_categories
  has_many :categories, through: :item_categories
  has_attached_file :image, styles: {:medium => "300x300#", :thumb => "100x100"}
  validates_attachment :image, content_type: {content_type: ["image/jpeg", "image/jpeg", "image/png", "image/gif"]}
  scope :active, -> {where(active: true)}

  def self.search(query)
    where("lower(TITLE) like lower(?)", "%#{query}%")
  end
  
  def active?
    self.active == true
  end

  def vegetarian?
    categories.include? Category.where(title: "vegetarian").first
  end
  
  def average_rating
    average = self.reviews.map do |review|
      review.stars
    end
    round_rating(average)
  end

  def round_rating(average)
    if !average.empty?
      ((average.reduce(:+) / self.reviews.size) * 2.0).round / 2.0
    else
      0
    end
  end
end
