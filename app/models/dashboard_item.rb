class DashboardItem < ApplicationRecord
  validates :item_type, :item_sub_type, presence: true
  include Dashboard::National
  include Dashboard::State

  ITEM_TYPE = %w[national state constituency].freeze
  ITEM_SUBTYPE = %w[poll statistics statistics_ac statistics_pc popular_candidates popular_influencers].freeze

  ITEM_TYPE.each do |item|
    define_method "is_type_#{item}?".to_sym do
      item == item_type
    end
  end

  ITEM_SUBTYPE.each do |item|
    define_method "is_sub_type_#{item}?".to_sym do
      item == item_sub_type
    end
  end
end
