json.data do
  json.parliament_constituency_id @constituency.parent.id if @constituency&.is_assembly?

  json.popular_candidates do
    json.partial! 'api/v1/common/candidatures', locals: { candidates_data: @candidates_data }
  end
  json.popular_influencers do
    json.partial! 'api/v1/common/influencers', locals: { influencers_data: @influencers_data }
  end

  json.polls do
    if @national_poll
      json.national do
        json.extract! @national_poll, :id, :question, :poll_options
      end
    end
    if @state_poll
      json.state do
        json.extract! @state_poll, :id, :question, :poll_options
      end
    end
    if @constituency_poll
      json.constituency do
        json.extract! @constituency_poll, :id, :question, :poll_options
      end
    end
  end

  if @top_parties
    json.top_parties do
      json.array! @top_parties, partial: 'api/v1/constituencies/top_party', as: :party
    end
  end

  if @top_parties_pc
    json.top_parties_pc do
      json.array! @top_parties_pc, partial: 'api/v1/constituencies/top_party', as: :party
    end
  end

  if @top_parties_state_level
    json.cache! ['v1', @dashboard_item_stats] do
      json.parties_data do
        json.top_parties_by_votes do
          json.array! @top_parties_state_level.top_parties_by_votes, partial: 'api/v1/constituencies/top_party', as: :party
        end

        json.top_parties_by_constituencies do
          json.array! @top_parties_state_level.top_parties_by_constituencies, partial: 'api/v1/country_states/top_parties_by_constituencies', as: :party
        end

        json.constituencies do
          json.array! @top_parties_state_level.constituencies, partial: 'api/v1/country_states/constituency', as: :constituency
        end

        json.image @dashboard_item_stats.image_obj
        json.seat_count @dashboard_item_stats.assembly_seats_count
        json.state_name @dashboard_item_stats.state_name
      end
    end
  end

  if @top_parties_national_level
    json.cache! ['v1', @dashboard_item_stats] do
      json.parties_data do
        json.top_parties_by_votes do
          json.array! @top_parties_national_level.top_parties_by_votes, partial: 'api/v1/constituencies/top_party', as: :party
        end

        json.top_parties_by_constituencies do
          json.array! @top_parties_national_level.top_parties_by_constituencies, partial: 'api/v1/country_states/top_parties_by_constituencies', as: :party
        end

        json.constituencies do
          json.array! @top_parties_national_level.constituencies, partial: 'api/v1/country_states/constituency', as: :constituency
        end
        json.image @dashboard_item_stats.image_obj
        json.seat_count @dashboard_item_stats.parliamentary_seats_count
      end
    end
  end
end
json.status_code 1
