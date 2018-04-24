class Admin::ProfessionsController < ApplicationController
  layout 'admin'

  def index
    @professions = Profession.all
  end

  def new
    @profession = Profession.new
  end

  def create
    @profession = Profession.new(profession_params)

    if @profession.save
      redirect_to admin_professions_path
    else
      render action: :new
    end
  end

  def edit
    @profession = Profession.find(params.permit(:id)[:id])
  end

  def update
    @profession = Profession.find(params.permit(:id)[:id])

    if @profession.update_attributes(profession_params)
      redirect_to admin_professions_path
    else
      render action: :edit
    end
  end

  def destroy; end

  private

  def profession_params
    params.require(:profession).permit(:name)
  end
end
