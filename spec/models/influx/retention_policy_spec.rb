require 'rails_helper'

RSpec.describe Influx::RetentionPolicy, type: :model, ci: !ENV["CI_NAME"].blank? do
  it "should create default retention policy" do
    db = Influx::Database.new
    db.create!
    expect(db.exists?).to be_truthy
    rp = Influx::RetentionPolicy.new(database: db)

    db.destroy!
    expect(db.exists?).to be_falsey
  end

  it "should create all retention polices" do
    db = Influx::Database.new
    db.create!
    expect(db.exists?).to be_truthy
    rp = Influx::RetentionPolicy.new(database: db)

    rp.create_all_rps!
    expect(rp.does_last_3_hrs_exists?).to be_truthy
    expect(rp.does_last_24_hrs_exists?).to be_truthy
    expect(rp.does_last_week_exists?).to be_truthy
    expect(rp.does_last_month_exists?).to be_truthy
    expect(rp.does_since_the_beginning_exists?).to be_truthy

    rp.destroy_all_rps!
    expect(rp.does_last_3_hrs_exists?).to be_falsey
    expect(rp.does_last_24_hrs_exists?).to be_falsey
    expect(rp.does_last_week_exists?).to be_falsey
    expect(rp.does_last_month_exists?).to be_falsey
    expect(rp.does_since_the_beginning_exists?).to be_falsey

    db.destroy!
    expect(db.exists?).to be_falsey
  end
end
