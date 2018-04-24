class Web::ConstituenciesController < ApplicationController
  def show
    @constituency = Constituency.find_by(slug: params[:id])
  end

  def map
    @constituency = Constituency.find_by(slug: params[:constituency_id])
    @map = @constituency.map
    if @map
      @zoom_level = @constituency.is_assembly? ? 10 : 8
      @lon = @constituency.center['lon']
      @lat = @constituency.center['lat']
      @bounding_coords = @constituency.bounding_coords

      @geojson = @constituency.geojson
    end
  end
end
