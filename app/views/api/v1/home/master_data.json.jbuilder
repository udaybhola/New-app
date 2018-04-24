json.cache! ['v1', 'master-data'] do
  json.data do
    json.religions Religion.all, partial: 'api/v1/common/religion', as: :religion
    json.castes Caste.all, partial: 'api/v1/common/caste', as: :caste
    json.professions Profession.all, partial: 'api/v1/common/profession', as: :profession
    json.educations Education.all, partial: 'api/v1/common/education', as: :education
    json.country_states CountryState.all, partial: 'api/v1/common/country_state', as: :country_state
  end
  json.status_code 1
end
