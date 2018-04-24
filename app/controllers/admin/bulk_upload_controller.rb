class Admin::BulkUploadController < ApplicationController
  before_action :authenticate_admin!
  layout "admin"

  before_action :set_election

  def new
    @bulk_file = BulkFile.new
  end

  def create
    @bulk_file = BulkFile.new(bulk_file_params)
    @bulk_file.election = @election
    if @bulk_file.save
      redirect_to admin_election_path(@election)
    else
      render action: :new
    end
  end

  private

  def set_election
    @election = Election.find(params.permit(:election_id)[:election_id])
  end

  def bulk_file_params
    params.require(:bulk_file).permit(:file)
  end
end
