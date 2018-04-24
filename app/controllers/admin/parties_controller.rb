class Admin::PartiesController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  def index
    @parties = Party.all.page params[:page]
  end

  def new
    @party = Party.new
  end

  def create
    @party = Party.new(party_params)

    if @party.save
      redirect_to admin_parties_path
    else
      render action: 'new'
    end
  end

  def edit
    @party = Party.find(params[:id])
  end

  def update
    @party = Party.find(params[:id])

    if @party.update_attributes(party_params)
      redirect_to admin_parties_path
    else
      render action: 'edit'
    end
  end

  private

  def party_params
    params.require(:party).permit(
      :abbreviation,
      :name,
      :image,
      :color,
      :phone,
      :phone2,
      :email,
      :website,
      :twitter,
      :facebook
    )
  end
end
