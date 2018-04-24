class Web::PollsController < ApplicationController
  def show
    @poll = Poll.find(params[:id])
  end
end
