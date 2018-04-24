class Admin::CandidaturesController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  before_action :set_election

  def new
    @candidature = Candidature.new

    if params.permit(:candidate_id)[:candidate_id]
      @candidate = Candidate.find(params.permit(:candidate_id)[:candidate_id])
    end
  end

  def create
    @candidature = Candidature.new(candidature_params)
    @candidature.election = @election

    if @candidature.save
      redirect_to admin_election_path(@election)
    else
      render action: 'new'
    end
  end

  def edit
    @candidature = Candidature.find(params[:id])
    @candidature.generate_share_link
    @candidate = @candidature.candidate
  end

  def update
    @candidature = Candidature.find(params[:id])
    @candidate = @candidature.candidate

    if @candidature.update_attributes(candidature_params)
      redirect_to admin_election_path(@election)
    else
      render action: 'edit'
    end
  end

  def destroy
    @candidature = Candidature.find(params[:id])
    if @candidature.destroy
      redirect_to admin_election_path(@election)
    else
      Rails.logger.debug "error while deleting candidature : #{@candidature.errors.messages}"
      render action: 'edit'
    end
  end

  private

  def set_election
    @election = Election.find(params.permit(:election_id)[:election_id])
    @constituencies = if @election.kind == Election::KIND_ASSEMBLY
                        @election.country_state.try(:constituencies).try(:assembly)
                      else
                        Constituency.parliamentary
                      end
  end

  def candidature_params
    params.require(:candidature).permit(:candidate_id, :party_id, :constituency_id, :declared, :result, :manifesto)
  end
end
