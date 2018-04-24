class CountryState < ApplicationRecord
  has_many :districts
  has_many :constituencies
  has_many :elections
  has_one :map, as: :mappable

  has_many :posts, as: :region
  has_many :issues, as: :region
  has_many :polls, as: :region
  has_many :comments, through: :constituencies

  validates :name, presence: true
  alias_attribute :abbreviation, :code

  before_save :generate_slug

  default_scope { order('name ASC') }

  attr_accessor :map_link

  def generate_slug
    self.slug = name.parameterize
  end

  def assembly_constituencies
    constituencies.where("constituencies.kind = ?", "assembly")
  end

  def assembly_constituencies_with_maps
    constituencies.where("constituencies.kind = ?", "assembly").reject { |item| item.map.nil? }
  end

  def parliamentary_constituencies
    constituencies.where("constituencies.kind = ?", "parliamentary")
  end

  def self.parliamentary_constituencies
    Constituency.where("constituencies.kind = ?", "parliamentary")
  end

  def self.parliamentary_constituencies_with_maps
    Constituency.where("constituencies.kind = ?", "parliamentary").reject { |item| item.map.nil? }
  end

  def admin_poll
    polls.dashboard.first
  end

  def current_assembly_election
    elections.where(kind: Election::KIND_ASSEMBLY).order('starts_at desc').first
  end

  def self.current_parliamentary_election
    Election.where(kind: Election::KIND_PARLIAMENT).order('starts_at desc').first
  end

  def has_launched?
    launched
  end

  def mark_launched
    update_attributes(launched: true)
  end

  def unmark_launched
    update_attributes(launched: false)
  end

  def assembly_constituencies_simplified_geojson(simplification_fator = 0.01)
    boundary_feature = map.to_simplified_feature(simplification_fator)
    assemblyfeatures = assembly_constituencies_with_maps.map { |item| item.map.to_simplified_feature(simplification_fator) }
    all_features = []
    all_features = all_features.push(boundary_feature)
    all_features = all_features.concat(assemblyfeatures)
    factory = RGeo::GeoJSON::EntityFactory.instance
    geojson = RGeo::GeoJSON.encode(factory.feature_collection(all_features))
  end

  def self.parliamentary_constituencies_simplified_geojson(simplification_fator = 0.01)
    parliamentary_features = parliamentary_constituencies_with_maps.map { |item| item.map.to_simplified_feature(simplification_fator) }
    all_features = []
    all_features = all_features.concat(parliamentary_features)
    factory = RGeo::GeoJSON::EntityFactory.instance
    geojson = RGeo::GeoJSON.encode(factory.feature_collection(all_features))
  end

  def self.generate_parliament_constituencies_geojson(force = false)
    cache_key = 'national-parliamentary-geojson'
    json = Rails.cache.read(cache_key) || {}
    if json.empty? || force
      geojson = parliamentary_constituencies_simplified_geojson(0.04)
      json = {
        geojson: geojson,
        lon: 79.088860,
        lat: 21.146633
      }
      Rails.cache.write(cache_key, json)
    end
    json
  end

  def generate_assembly_constituencies_geojson(force = false)
    if assembly_geojson.empty? || force
      geojson = assembly_constituencies_simplified_geojson(0.0001)
      self.assembly_geojson = geojson

      results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Centroid(shape)) as wkt from maps where id='#{map.id}'"
      if results&.first
        center = RGeo::Cartesian.preferred_factory.parse_wkt(results.first['wkt'])
        lon = center.x
        lat = center.y
        self.geo_center = { lon: lon, lat: lat }
      end
      save
    end
    assembly_geojson
  end

  def generate_geo_bounding_coords
    return if map.blank?
    bounding_box_results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Envelope(shape)) as wkt from maps where id='#{map.id}'"
    return if bounding_box_results.empty?
    bounding_polygon = RGeo::Cartesian.preferred_factory.parse_wkt(bounding_box_results.first['wkt'])
    self.geo_bounding_coords = bounding_polygon.coordinates[0]
    save
  end

  def generate_map_meta
    generate_assembly_constituencies_geojson(true)
    generate_geo_bounding_coords
  end
end
