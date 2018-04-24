class Admin::ConstituenciesController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  before_action :find_country_state

  def index
    @constituncies = if params.permit(:kind)[:kind] == 'assembly'
                       @country_state.constituencies.assembly
                     else
                       @country_state.constituencies.parliamentary
                     end
  end

  def new
    @constituency = Constituency.new
    @constituency.country_state = @country_state
  end

  def create
    @constituency = Constituency.new(constituency_params)

    if @constituency.save
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def edit
    @constituency = Constituency.find(params[:id])
  end

  def update
    @constituency = Constituency.find(params[:id])
    @country_states = CountryState.all.order('name ASC')

    if @constituency.update_attributes(constituency_params)
      redirect_to action: 'index'
    else
      render action: 'edit'
    end
  end

  def unlink_map
    @constituency = Constituency.find(params[:constituency_id])
    @map = @constituency.map

    @map.mappable = nil
    @map.save

    redirect_to action: 'index'
  end

  def link_map
    @constituency = Constituency.find(params[:constituency_id])
    @maps = if params.permit(:kind)[:kind] == 'assembly'
              Map.where(mappable_id: nil, kind: 'assembly').order('name ASC')
            else
              Map.where(mappable_id: nil, kind: 'parliamentary').order('name ASC')
            end
  end

  def save_map_link
    @constituency = Constituency.find(params[:constituency_id])
    @map = Map.find(params.require(:constituency).permit(:map_link)[:map_link])
    @map.mappable = @constituency
    @map.save

    redirect_to action: 'index'
  end

  private

  def find_country_state
    @country_state = CountryState.find(params[:country_state_id])
  end

  def constituency_params
    params.require(:constituency).permit(:name, :kind, :country_state_id)
  end
end
