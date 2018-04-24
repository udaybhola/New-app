class Admin::CountryStatesController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  def index
    @country_states = CountryState.all.order('name ASC')
  end

  def show
    @country_state = CountryState.find(params[:id])
    @assembly_constituencies = @country_state.constituencies.assembly
    @parliamentary_constituencies = @country_state.constituencies.parliamentary
    @elections = @country_state.elections

    @user_polls = @country_state.polls.user
    @user_issues = @country_state.posts.user

    @admin_polls = @country_state.polls.admin
    @admin_issues = @country_state.issues.admin
    @region_type = "CountryState"
    @region_id = @country_state.id
  end

  def new
    @country_state = CountryState.new
  end

  def create
    @country_state = CountryState.new(country_state_params)

    if @country_state.save
      redirect_to action: 'index'
    else
      render action: 'new'
    end
  end

  def edit
    @country_state = CountryState.find(params[:id])
  end

  def update
    @country_state = CountryState.find(params[:id])

    if @country_state.update_attributes(country_state_params)
      redirect_to action: 'index'
    else
      render action: 'edit'
    end
  end

  def unlink_map
    @country_state = CountryState.find(params[:country_state_id])
    @map = @country_state.map

    @map.mappable = nil
    @map.save

    redirect_to action: 'index'
  end

  def link_map
    @country_state = CountryState.find(params[:country_state_id])
    @maps = Map.where(mappable_id: nil, kind: 'state')
  end

  def save_map_link
    @country_state = CountryState.find(params[:country_state_id])
    @map = Map.find(params.require(:country_state).permit(:map_link)[:map_link])
    @map.mappable = @country_state
    @map.save

    redirect_to action: 'index'
  end

  private

  def country_state_params
    params.require(:country_state).permit(:name, :code, :launched)
  end
end
