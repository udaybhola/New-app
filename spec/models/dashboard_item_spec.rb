require 'rails_helper'

RSpec.describe DashboardItem, type: :model do
  it "should accept types and sub types" do
    DashboardItem::ITEM_TYPE.each do |itype|
      DashboardItem::ITEM_SUBTYPE.each do |isubtype|
        item = build(:dashboard_item)
        item.item_type = itype
        item.item_sub_type = isubtype
        expect(item).to be_valid
        expect(item.save).to be_truthy
        expect(item.send("is_type_#{itype}?".to_sym)).to be_truthy
        expect(item.send("is_sub_type_#{isubtype}?".to_sym)).to be_truthy
      end
    end
  end

  it "should only have one national statistics item" do
    stats_one = DashboardItem.national_statistics
    expect(stats_one.id).not_to be_empty
    stats_two = DashboardItem.national_statistics
    stats_three = DashboardItem.national_statistics
    expect(stats_one).to eq(stats_two)
    expect(stats_one).to eq(stats_three)
  end
end
