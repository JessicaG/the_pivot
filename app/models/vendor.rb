class Vendor < ActiveRecord::Base
  include US
  geocoded_by :set_address
  after_validation :geocode

  has_many :items
  has_many :vendor_orders

  before_save :set_default_slug

  validates :name, presence: true #, uniqueness: true <- this blows up lots of tests?
  validates :slug, uniqueness: true
  validates :street, presence: true
  validates :city, presence: true
  validates :state, presence: true, inclusion: states
  validates :zip, presence: true, format: { with: /\d{5}\d*/ }

  scope :approved, -> { where(approved: true) }
  scope :not_approved, -> { where(approved: false) }

  def active?
    approved?
  end

  def set_address
    "#{self.street} " + "#{self.city}, " + "#{self.state} " + "#{self.zip}"
  end

  # def vendor_items
  #   @vendor_items = Vendor.find_by(slug: "responder").items
  # end

  def online?
    self.online ? 'Yes' : 'No'
  end

  def online=(value)
    value.downcase!
    if value == 'yes'
      write_attribute(:online, true)
    else
      write_attribute(:online, false)
    end
  end

  def approved?
    self.approved ? 'Yes' : 'No'
  end

  def approved=(value)
    value.downcase!
    if value == 'yes'
      write_attribute(:approved, true)
    else
      write_attribute(:approved, false)
    end
  end

  def display?
    approved? == 'Yes' && online? == 'Yes'
  end

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
