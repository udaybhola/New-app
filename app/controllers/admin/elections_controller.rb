class Admin::ElectionsController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  before_action :set_election, only: [:show]

  def index
    @elections = Election.all.page params[:page]
  end

  def show
    @candidatures = @election.candidatures
    @bulk_files = @election.bulk_files.order('created_at desc')

    if params.permit(:constituency)[:constituency]
      @constituency = Constituency.find_by_slug(params.permit(:constituency)[:constituency])
    end

    if @constituency
      @candidatures = @candidatures.where(constituency_id: @constituency.id)
    end

    @candidature_count = @candidatures.count

    @candidatures = @candidatures.select(:candidate_id).distinct.page params[:page]
  end

  def new
    @election = Election.new
  end

  def create
    @election = Election.new(election_params)

    if @election.save
      redirect_to admin_path
    else
      render action: 'new'
    end
  end

  def edit
    @election = Election.find(params.permit(:id)[:id])
  end

  def update
    @election = Election.find(params.permit(:id)[:id])

    if @election.update_attributes(election_params)
      redirect_to admin_path
    else
      render action: 'edit'
    end
  end

  private

  def set_election
    @election = Election.find(params.permit(:id)[:id])
    @constituencies = if @election.kind == Election::KIND_ASSEMBLY
                        @election.country_state.try(:constituencies).try(:assembly)
                      else
                        Constituency.parliamentary
                      end
  end

  def election_params
    params.require(:election).permit(
      :kind,
      :country_state_id,
      'starts_at(1i)',
      'starts_at(2i)',
      'starts_at(3i)',
      'ends_at(1i)',
      'ends_at(2i)',
      'ends_at(3i)'

    )
  end
end
