module Dashboard
  module National
    extend ActiveSupport::Concern
    include Dashboard::Common

    def process_stats_nation(force = false)
      data = Leaderboards.parties.top_parties({})
      build_state_nation_party_response(data, force)
    end

    def generate_image_national
      image_maker_url = ENV["CONSTITUENCY_IMAGE_MAKER_URL"]
      raise "CONSTITUENCY_IMAGE_MAKER_URL env not set" if image_maker_url.blank?
      url = "#{image_maker_url}/snapshot?url=#{parties_map_states_url}&width=900&height=900"
      image_name = "national-statistics-#{SecureRandom.hex(4)}"
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

    def parliamentary_seats_count
      CountryState.parliamentary_constituencies.count
    end

    class_methods do
      def national_statistics
        where(item_type: 'national', item_sub_type: 'statistics', item_type_resource_id: nil).first || DashboardItem.create!(item_type: 'national', item_sub_type: 'statistics')
      end
    end
  end
end
