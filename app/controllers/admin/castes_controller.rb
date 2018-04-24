class Admin::CastesController < ApplicationController
  layout 'admin'

  def index
    @castes = Caste.all
  end

  def new
    @caste = Caste.new
  end

  def create
    @caste = Caste.new(caste_params)

    if @caste.save
      redirect_to admin_castes_path
    else
      render action: :new
    end
  end

  def edit
    @caste = Caste.find(params.permit(:id)[:id])
  end

  def update
    @caste = Caste.find(params.permit(:id)[:id])

    if @caste.update_attributes(caste_params)
      redirect_to admin_castes_path
    else
      render action: :edit
    end
  end

  def destroy; end

  private

  def caste_params
    params.require(:caste).permit(:name)
  end
end
