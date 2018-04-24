require 'rails_helper'

RSpec.describe Influx::EntityInstances, type: :model, ci: !ENV["CI_NAME"].blank? do
  before(:each) do
    root_db = Influx::EntityInstances.root_db
    root_db.create!
    expect(root_db.exists?).to be_truthy
    rp = Influx::EntityInstances.rp
    rp.create_all_rps!
  end

  after(:each) do
    root_db = Influx::EntityInstances.root_db
    root_db.destroy!
    expect(root_db.exists?).to be_falsey
    Influx::EntityInstances.reset
  end

  it "Should create db and all rps" do
    rp = Influx::EntityInstances.rp
    expect(rp.does_last_3_hrs_exists?).to be_truthy
    expect(rp.does_last_24_hrs_exists?).to be_truthy
    expect(rp.does_last_week_exists?).to be_truthy
    expect(rp.does_last_month_exists?).to be_truthy
    expect(rp.does_since_the_beginning_exists?).to be_truthy
  end

  it "should create candidature scoring cqs" do
    measurement = Influx::EntityInstances.candidature_scoring_measurement
    measurement.create_cqs!
    expect(measurement.do_all_cqs_exist?).to be_truthy
    measurement.destroy_cqs!
    expect(measurement.do_all_cqs_exist?).to be_falsey
  end

  it "should create influencer scoring cqs" do
    measurement = Influx::EntityInstances.influencer_scoring_measurement
    measurement.create_cqs!
    expect(measurement.do_all_cqs_exist?).to be_truthy
    measurement.destroy_cqs!
    expect(measurement.do_all_cqs_exist?).to be_falsey
  end
end
