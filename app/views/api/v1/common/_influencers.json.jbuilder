json.array! influencers_data do |influencer|
  json.influencer_id influencer.influencer_id
  json.influencer_name influencer.influencer_name
  json.score influencer.score
  json.rank influencer.rank
  json.constituency influencer.constituency
  json.influencer_profile_pic do
    if !influencer.influencer_profile_pic.file.nil? && influencer.influencer_profile_pic.respond_to?(:full_public_id)
      json.cloudinary do
        json.public_id influencer.influencer_profile_pic.file.public_id
      end
    end
  end
  json.constituency_id influencer.constituency_id
  json.has_cover influencer.has_cover_image
  json.cover_image influencer.cover_image
end
