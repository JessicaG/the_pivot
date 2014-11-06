class Vendor < ActiveRecord::Base
  has_many :items
  has_many :vendor_orders

  before_save :set_default_slug

  validates :name, presence: true #, uniqueness: true <- this blows up lots of tests?
  validates :slug, uniqueness: true

  # def vendor_items
  #   @vendor_items = Vendor.find_by(slug: "responder").items
  # end

  private

  def set_default_slug
    self.slug ||= generate_slug(self.name)
  end

  def generate_slug(name_to_slug)
    name_to_slug.gsub(/'/, '').parameterize
  end

  def find_vendor_name(vendor_id)
    Vendor.where(id: vendor_id).first.name
  end
end
