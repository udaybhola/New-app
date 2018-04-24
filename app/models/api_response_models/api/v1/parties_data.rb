module ApiResponseModels
  module Api
    module V1
      class PartiesData
        attr_accessor :id, :party_name, :party_image, :party_color

        def initialize(id, party_name, party_image, party_color = nil)
          @id = id
          @party_name = party_name
          @party_image = party_image
          @party_color = party_color
        end

        def self.fetch_from_active_record
          parties = Party.all
          all_parties_data = []
          parties.each do |party|
            all_parties_data << new(party.id, party.title, party.party_image_obj, party.color)
          end
          all_parties_data
        end

        def self.fetch_data
          fetch_from_active_record
        end

        def self.fetch_top_parties(constituency_id = nil, state_id = nil)
          return [] if Rails.env.test?
          content = []
          if constituency_id.blank? && state_id.blank?
            # nation
            content = Influx::Series.top_parties_of_nation(CountryState.current_parliamentary_election.id)
          elsif constituency_id.blank?
            # state
            cs = CountryState.find(state_id)
            content = Influx::Series.top_parties_of_state_ac(cs.current_assembly_election.id, state_id)
          else
            # constituency
            const = Constituency.find(constituency_id)
            if const.is_assembly?
              content = Influx::Series.top_parties_of_constituency_ac(const.current_election.id, constituency_id)
            elsif const.is_parliament?
              content = Influx::Series.top_parties_of_constituency_pc(const.current_election.id, constituency_id)
            end
          end
          content
        end
      end
    end
  end
end
