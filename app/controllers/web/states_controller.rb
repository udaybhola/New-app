class Web::StatesController < ApplicationController
  def show
    @state = CountryState.find_by(abbreviation: params[:id])
  end
end
