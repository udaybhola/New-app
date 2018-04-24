module Dashboard
  module Common
    extend ActiveSupport::Concern
    included do
      include Rails.application.routes.url_helpers
    end

    def build_state_nation_party_response(response_data, force = false)
      result = ApiResponseModels::CustomOstruct.new
      top_parties_by_votes = response_data.top_parties_by_votes.map do |item|
        dat = props_to_obj([:id, :party_name, :votes, :percentage, :party_abbreviation, :party_color], item)
        dat[:image] = item.party_image_obj
        dat
      end
      top_parties_by_constituencies = response_data.top_parties_by_constituencies.map do |item|
        props_to_obj([:party_id, :constituencies_won], item)
      end
      constituencies = response_data.constituencies.map do |item|
        props_to_obj([:id, :party_id, :votes], item)
      end
      result.top_parties_by_votes = top_parties_by_votes
      result.top_parties_by_constituencies = top_parties_by_constituencies
      result.constituencies = constituencies
      existing_data = data
      self.data = JSON.parse(result.as_serialized_json)
      existing_map_dat = {}
      existing_map_dat = existing_data["data"]["attributes"]["top_parties_by_constituencies"] if existing_data && existing_data["data"] && existing_data["data"]["attributes"] && existing_data["data"]["attributes"]["top_parties_by_constituencies"]
      new_map_dat = data["data"]["attributes"]["top_parties_by_constituencies"]
      begin
        if existing_map_dat == new_map_dat && !cloudinary_response.empty? && !force
          puts "No need to generate image"
        else
          puts "Need to generate image"
          generate_image
        end
        save
      rescue Error, Exception => e
        puts "Caught error generating image for constituency with id #{id} - #{e.message}"
        Rails.logger.error "Caught error generating image for constituency with id #{id} - #{e.message}"
      end
    end

    def process_stats(force = false)
      if is_type_national?
        process_stats_nation(force)
      elsif is_type_state?
        process_stats_state(force)
      end
    end

    def generate_image
      if is_type_national?
        generate_image_national
      elsif is_type_state?
        generate_image_state
      end
    end

    def props_to_obj(props, target)
      dat = {}
      props.each do |prop|
        dat[prop] = target.send(prop)
        dat[prop] = dat[prop].to_i if [:votes, :constituencies_won].include? prop
        dat[prop] = dat[prop].to_f if [:percentage].include? prop
      end
      dat
    end

    def image_obj
      return { cloudinary: { public_id: cloudinary_response["public_id"] } } unless cloudinary_response.empty?
      nil
    end
  end
end
