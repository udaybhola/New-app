class BulkUploadJob < ApplicationJob
  require 'csv'
  require "open-uri"

  queue_as :default

  def perform(bulk_upload_id)
    Rails.logger.debug "Start: Start bulk upload process"
    @bulk_file = BulkFile.find(bulk_upload_id)

    @bulk_file.status = "processing file at 0%"
    @bulk_file.save

    election = @bulk_file.election
    candidates_csv = URI.parse(@bulk_file.file_url).read
    candidates = CSV.parse(candidates_csv, headers: true)

    candidates.each_with_index do |candidate, index|
      profile = Profile.candidate.find_or_create_by(name: candidate['Name'].titleize, date_of_birth: DateTime.new(candidate['Birth Year'].to_i, 1, 1))

      profile.gender    = candidate['Gender']     unless candidate['Gender'].blank?
      profile.education = candidate['Education']  unless candidate['Education'].blank?
      profile.qualification = candidate['Qualification']  unless candidate['Qualification'].blank?
      profile.phone     = candidate['Phone']      unless candidate['Phone'].blank?
      profile.phone2    = candidate['Phone 2']    unless candidate['Phone 2'].blank?
      profile.email     = candidate['Email']      unless candidate['Email'].blank?
      profile.website   = candidate['Website']    unless candidate['Website'].blank?
      profile.twitter   = candidate['Twitter']    unless candidate['Twitter'].blank?
      profile.facebook  = candidate['Facebook']   unless candidate['Facebook'].blank?
      profile.pincode   = candidate['Pincode']    unless candidate['Pincode'].blank?

      profile.income = candidate['Income']                  unless candidate['Income'].blank?
      profile.assets = candidate['Assets']                  unless candidate['Assets'].blank?
      profile.liabilities = candidate['Liabilities']        unless candidate['Liabilities'].blank?
      profile.criminal_cases = candidate['Criminal Cases']  unless candidate['Criminal Cases'].blank?

      profile.religion  = Religion.find_or_create_by(name: candidate['Religion'])      unless candidate['Religion'].blank?
      profile.caste     = Caste.find_or_create_by(name: candidate['Caste'])            unless candidate['Caste'].blank?
      profile.profession = Profession.find_or_create_by(name: candidate['Profession']) unless candidate['Profession'].blank?

      profile.remote_profile_pic_url = candidate['Profile Pic']    unless candidate['Profile Pic'].blank?
      profile.remote_cover_photo_url = candidate['Cover Photo']    unless candidate['Cover Photo'].blank?
      profile.save

      unless profile.candidate
        profile.candidate = Candidate.create(phone_number: candidate['Phone'].to_s)
        profile.save
      end

      profile_candidate = profile.candidate
      profile_candidate.label = Label.find_or_create_by(name: candidate['Label'].downcase) unless candidate['Label'].blank?
      profile_candidate.save

      unless candidate['Constituency'].blank?
        case election.kind
        when Election::KIND_PARLIAMENT
          constituency = Constituency.parliamentary.find_by_name(candidate['Constituency'].downcase)
        when Election::KIND_ASSEMBLY
          constituency = election.country_state.constituencies.assembly.find_by_name(candidate['Constituency'].downcase)
        end

        if constituency && !candidate['Party'].blank?
          candidature = profile.candidate.candidatures.find_or_create_by(election_id: election.id, constituency_id: constituency.id)

          candidature.party = Party.find_or_create_by(abbreviation: candidate['Party'])
          candidature.declared = true
          candidature.result = candidate['Result']                 unless candidate['Result'].blank?
          candidature.votes_received = candidate['Votes Received'] unless candidate['Votes Received'].blank?
          candidature.save
        end
      end

      @bulk_file.status = "processing file at #{((index.to_f / candidates.count.to_f) * 100).to_i}%"
      @bulk_file.save
    end

    @bulk_file.status = "candidate data processed and added"
    # @bulk_file.remove_file!
    @bulk_file.save
  end
end
