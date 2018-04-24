module ApiResponseModels
  module Api
    module V1
      class PartyProfileData
        include ProfileBuilder
        attr_accessor :id, :party_name, :info, :manifesto, :membership_info, :contact_info, :party_image, :party_abbreviation, :party_color

        def initialize(id, party_name, info, manifesto, contact_info, membership_info, party_image, party_abbreviation, _party_color = nil)
          @id = id
          @party_name = party_name
          @info = info
          @manifesto = manifesto
          @contact_info = contact_info
          @membership_info = membership_info
          @party_image = party_image
          @party_abbreviation = party_abbreviation
        end

        def self.construct_party_profile(party, user)
          manifesto = party.manifesto
          manifesto_item = CustomOstruct.new
          unless manifesto.file.nil?
            manifesto_item.url = manifesto.url
            result = Cloudinary::Api.resource(@manifesto.file.public_id.to_s, pages: true)
            manifesto_item.total_pages = result["pages"]
          end
          info = party.info
          contact_info = construct_contact_info(party)
          membership_info = construct_membership_data(party, user)
          new(party.id, party.title, info, manifesto_item, contact_info, membership_info, party.image, party.abbreviation, party.color)
        end

        def self.construct_membership_data(party, user)
          membership_info = CustomOstruct.new
          membership_record = PartyMembership.find_by(user: user, party: party, is_valid: true)
          membership_info.is_member = membership_record&.is_valid
          membership_info.membership_id = membership_record.id if membership_record
          membership_info
        end

        def self.fetch_from_active_record(party_id, user)
          party = Party.find(party_id)
          construct_party_profile(party, user)
        end

        def self.fetch_data(party_id, user)
          fetch_from_active_record(party_id, user)
        end
      end
    end
  end
end
