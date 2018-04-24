require 'rails_helper'

RSpec.describe "Home Controller Specs" do
  before(:each) do
    data_helper_create_data_set
  end

  describe "GET /api/v1/master-data" do
    it "should retrieve master data required for app to function" do
      get api_v1_master_data_url, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      religions_count = Religion.all.count
      castes_count = Caste.all.count
      professions_count = Profession.all.count
      educations_count = Education.all.count
      states_count = CountryState.all.count
      districts_count = District.all.count
      expect(data["religions"].count).to eq(religions_count)
      expect(data["castes"].count).to eq(castes_count)
      expect(data["professions"].count).to eq(professions_count)
      expect(data["educations"].count).to eq(educations_count)
      expect(data["country_states"].count).to eq(states_count)
    end
  end

  describe "GET /api/v1/dashboard-data" do
    it "should give 200 and output data if constituency id is present" do
      constituency = Constituency.find_by(name: "Bengaluru South Constituency")
      constituency_poll = Poll.new(user: nil, region: constituency, archived: false, show_on_dashboard: true, question: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                                   poll_options: rand(2..4).times.map { |_i| PollOption.create(answer: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote) })
      constituency_poll.save

      state_poll = Poll.new(user: nil, region: constituency.country_state, archived: false, show_on_dashboard: true, question: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                            poll_options: rand(2..4).times.map { |_i| PollOption.create(answer: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote) })
      state_poll.save

      national_poll = Poll.new(user: nil, archived: false, show_on_dashboard: true, question: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote,
                               poll_options: rand(2..4).times.map { |_i| PollOption.create(answer: [Faker::RickAndMorty, Faker::BackToTheFuture, Faker::HitchhikersGuideToTheGalaxy].sample.quote) })
      national_poll.save
      get api_v1_dashboard_data_url, params: { constituency_id: constituency.id }, headers: DataHelper::HEADERS
      parsed_body = JSON.parse(response.body)
      data = parsed_body["data"]
      expect(data["popular_influencers"].count).not_to eq(0)
      expect(data["popular_candidates"].count).not_to eq(0)
      if constituency.is_assembly?
        expect(data["polls"]["constituency"].count).not_to eq(0)
      elsif constituency.is_parliament?
        expect(data["polls"]["state"].count).not_to eq(0)
      else
        expect(data["polls"]["national"].count).not_to eq(0)
      end
    end
  end
end
