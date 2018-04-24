class Web::InfluencersController < ApplicationController
  def show
    @influencer = User.find(params[:id])
  end
end
