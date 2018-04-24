class Admin::LabelsController < ApplicationController
  layout 'admin'

  def new
    @label = Label.new
  end

  def create
    @label = Label.new(label_params)

    if @label.save
      redirect_to admin_path
    else
      render action: :new
    end
  end

  def edit
    @label = Label.find(params.permit(:id)[:id])
  end

  def update
    @label = Label.find(params.permit(:id)[:id])

    if @label.update_attributes(label_params)
      redirect_to admin_path
    else
      render action: :edit
    end
  end

  def destroy; end

  private

  def label_params
    params.require(:label).permit(:name, :color)
  end
end
