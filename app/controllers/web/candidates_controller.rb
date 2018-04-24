class Web::CandidatesController < ApplicationController
  def show
    @candidature = Candidature.find(params[:id])
    @candidate = @candidature.candidate
  end
end
