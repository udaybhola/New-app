class Admin::CandidatesController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  before_action :set_election

  def new
    @candidate = Candidate.new
    @candidate.build_profile
    @candidate.candidatures.build
  end

  def create
    @candidate = Candidate.new(candidate_params)
    @candidate.candidatures.first.election = @election

    if @candidate.save
      redirect_to admin_election_path(@election)
    else
      render action: 'new'
    end
  end

  def edit
    @candidate = Candidate.find(params.permit(:id)[:id])
  end

  def update
    @candidate = Candidate.find(params.permit(:id)[:id])

    if @candidate.update_attributes(candidate_params)
      redirect_to admin_election_path(@election)
    else
      render action: 'edit'
    end
  end

  def link_page
    @candidate = Candidate.find(params.permit(:id)[:id])
  end

  def link
    @candidate = Candidate.find(params.permit(:id)[:id])
    if @candidate.update_attributes(candidate_params)
      redirect_to admin_election_path(@election)
    else 
      render 'link_page'  
    end
  end

  private

  def candidate_params
    params.require(:candidate).permit(
      :phone_number,
      :label_id,
      :link_phone_number,
      :should_link_with_phone_number,
      profile_attributes: [
        :id,
        :name,
        'date_of_birth(1i)',
        'date_of_birth(2i)',
        'date_of_birth(3i)',
        :gender,
        :religion_id,
        :caste_id,
        :education,
        :profession_id,
        :phone,
        :phone2,
        :email,
        :website,
        :twitter,
        :facebook,
        :pincode,
        :income,
        :assets,
        :liabilities,
        :criminal_cases,
        :profile_pic,
        :cover_photo,
        :qualification
      ],
      candidatures_attributes: [
        :party_id,
        :constituency_id,
        :declared,
        :result,
        :manifesto
      ]
    )
  end

  def set_election
    @election = Election.find(params.permit(:election_id)[:election_id])
    @constituencies = if @election.kind == Election::KIND_ASSEMBLY
                        @election.country_state.try(:constituencies).try(:assembly)
                      else
                        Constituency.parliamentary
                      end
  end
end
