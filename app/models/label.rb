class Label < ApplicationRecord
  has_many :candidates

  validates_presence_of :name
  validates :color, css_hex_color: true, allow_blank: true

  before_validation :add_default_color

  default_scope { order('name ASC') }

  def add_default_color
    self.color = "#8A96A0" if color.blank?
  end
end
