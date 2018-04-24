module Dashboard
  module State
    extend ActiveSupport::Concern
    include Dashboard::Common

    def process_stats_state(force = false)
      cs = CountryState.find(item_type_resource_id)
      data = Leaderboards.parties.top_parties(state_id: cs.id)
      build_state_nation_party_response(data, force)
    end

    def generate_image_state
      cs = CountryState.find(item_type_resource_id)
      image_maker_url = ENV["CONSTITUENCY_IMAGE_MAKER_URL"]
      raise "CONSTITUENCY_IMAGE_MAKER_URL env not set" if image_maker_url.blank?
      url = "#{image_maker_url}/snapshot?url=#{map_state_parties_url(state_id: cs.code)}&width=900&height=900"
      image_name = "state-statistics-#{cs.code}-#{SecureRandom.hex(4)}"
      response = HTTParty.get(url)
      return if response.code != 200
      unless cloudinary_response.empty?
        puts "Deleting old cloudinary details #{cloudinary_response}"
        Cloudinary::Api.delete_resources([cloudinary_response['public_id']])
      end
      base64 = Base64.encode64(response.body.to_s)
      dat = "data:image/png;base64,#{base64}"
      self.cloudinary_response = Cloudinary::Uploader.upload(dat, public_id: image_name)
      puts "New response #{cloudinary_response}"
    end

    def state_name
      cs = CountryState.find(item_type_resource_id)
      cs.name.titleize
    end

    def assembly_seats_count
      cs = CountryState.find(item_type_resource_id)
      cs.assembly_constituencies.count
    end

    class_methods do
      def statistics_of_state(cs)
        where(item_type: 'state', item_sub_type: 'statistics', item_type_resource_id: cs.id).first || DashboardItem.create!(item_type: 'state', item_sub_type: 'statistics', item_type_resource_id: cs.id)
      end
    end
  end
end
