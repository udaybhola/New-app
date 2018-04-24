class Map < ApplicationRecord
  belongs_to :mappable, polymorphic: true, optional: true

  def to_simplified_geojson(simplification_fator = 0.01)
    feature = to_simplified_feature(simplification_fator)
    return RGeo::GeoJSON.encode(feature) if feature
  end

  def to_geojson
    # factory = RGeo::GeoJSON::EntityFactory.instance
    # feature = factory.feature(shape, nil, name: mappable.try(:name).try(:capitalize))
    # RGeo::GeoJSON.encode(feature)
    to_simplified_geojson
  end

  def to_simplified_feature(simplification_fator = 0.01)
    results = ActiveRecord::Base.connection.exec_query "select id, shape, ST_AsText(ST_Simplify(shape, #{simplification_fator}, true)) as simplified_shape from maps where id='#{id}'"
    if results&.first
      factory = RGeo::GeoJSON::EntityFactory.instance
      geom = RGeo::Cartesian.preferred_factory.parse_wkt(results.first["simplified_shape"])
      feature = factory.feature(geom, mappable.try(:id) || 'id', name: mappable.try(:name).try(:capitalize) || 'map', id: mappable.try(:id) || 'id')
    end
  end

  def to_feature
    factory = RGeo::GeoJSON::EntityFactory.instance
    factory.feature(shape, id, name: name.try(:capitalize), id: id)
  end

  def self.to_geojson_collection(models)
    factory = RGeo::GeoJSON::EntityFactory.instance
    features = models.map(&:to_feature)
    RGeo::GeoJSON.encode factory.feature_collection features
  end
end
