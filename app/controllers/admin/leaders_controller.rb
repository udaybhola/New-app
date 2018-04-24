
class Admin::LeadersController < ApplicationController
  before_action :authenticate_admin!
  layout 'admin'


  def index
    @filter = params.permit(:filter)[:filter] || ""
    @country_states = CountryState.all
    @elections=Election.all
    @candidatures = Candidature.all
    if params[:search]
      @candidatures = Candidature.search(params[:search])
      # all_candidatures=Candidature.where(candidate_id: @candidates.id)
      # @candidatures=@candidates.candidature
    else
      @candidatures=Candidature.all
    end

    unless params[:country_state].blank?
      @country_state = CountryState.find_by_code(params[:country_state])
      @parliamentary_constituencies = @country_state.constituencies.parliamentary
      @assembly_constituencies = @country_state.constituencies.assembly
    end
    
    
    if !params[:election].blank?
      @election=Election.find(params[:election])
      all_candidatures = Candidature.where(election_id: @election).where.not(candidate_id: nil).order('created_at desc')
    elsif params[:constituency].blank?
        all_candidatures = Candidature.all;
    else
      @constituency = @country_state.constituencies.find_by_slug(params[:constituency])

      all_candidatures = if @constituency.parent.nil?
                    Candidature.where(constituency_id: @constituency.children.map(&:id)).where.not(candidate_id: nil).order('created_at desc')
                  else
                    @constituency.candidatures
                  end

    end
    @candidatures = if @filter==''
      all_candidatures
    end
  end
  def destroy
    @candidate=Candidate.find(params[:id])
    @candidate.destroy
    redirect_to admin_leaders_path
  end    
end
