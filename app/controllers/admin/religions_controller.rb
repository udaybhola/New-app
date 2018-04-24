class Admin::ReligionsController < ApplicationController
  layout 'admin'

  def index
    @religions = Religion.all
  end

  def new
    @religion = Religion.new
  end

  def create
    @religion = Religion.new(religion_params)

    if @religion.save
      redirect_to admin_religions_path
    else
      render action: :new
    end
  end

  def edit
    @religion = Religion.find(params.permit(:id)[:id])
  end

  def update
    @religion = Religion.find(params.permit(:id)[:id])

    if @religion.update_attributes(religion_params)
      redirect_to admin_religions_path
    else
      render action: :edit
    end
  end

  def destroy; end

  private

  def religion_params
    params.require(:religion).permit(:name)
  end
end
