require 'rails_helper'

RSpec.describe Influx::Database, type: :model, ci: !ENV["CI_NAME"].blank? do
  it "should not contain a db unless one is created" do
    db = Influx::Database.new
    expect(db.exists?).to be_falsey
  end

  it "should create and destroy database" do
    db = Influx::Database.new
    expect(db.exists?).to be_falsey
    db.create!
    expect(db.exists?).to be_truthy
    db.destroy!
    expect(db.exists?).to be_falsey
  end
end
