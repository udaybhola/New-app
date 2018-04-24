class Constituency < ApplicationRecord
  include Rails.application.routes.url_helpers
  mount_uploader :image, ImageUploader

  KIND_ASSEMBLY = "assembly".freeze
  KIND_PARLIAMENT = "parliamentary".freeze
  KIND_LOCAL = "local".freeze

  KINDS = [KIND_ASSEMBLY, KIND_PARLIAMENT, KIND_LOCAL].freeze

  belongs_to :country_state
  has_and_belongs_to_many :districts
  has_many :users
  has_many :candidatures
  has_many :posts, as: :region
  has_many :issues, as: :region
  has_many :polls, as: :region
  has_many :comments, through: :posts
  has_one :map, as: :mappable

  has_many :candidatures
  has_many :candidates, through: :candidatures

  has_many :children, class_name: 'Constituency', foreign_key: 'parent_id'
  belongs_to :parent, class_name: 'Constituency', optional: true, foreign_key: 'parent_id'

  validates :name, presence: true
  validates :country_state, presence: true

  before_save :set_kind, :generate_slug

  default_scope { order('name ASC') }
  scope :assembly, -> { where(kind: KIND_ASSEMBLY) }
  scope :parliamentary, -> { where(kind: KIND_PARLIAMENT) }

  attr_accessor :map_link

  store_accessor :map_meta,
                 :center,
                 :bounding_coords,
                 :geojson

  def generate_slug
    self.slug = "#{country_state.slug}-#{name.parameterize}-#{kind}"
  end

  def set_kind
    self.kind = parent_id ? "assembly" : "parliamentary"
  end

  def is_parliament?
    parent.nil?
  end

  def is_assembly?
    !parent.nil?
  end

  def current_election
    if is_assembly?
      country_state.current_assembly_election
    elsif is_parliament?
      CountryState.current_parliamentary_election
    end
  end

  def total_votes(election)
    candidatures.where(election: election).map(&:total_votes).reduce(:+)
  end

  def image_obj
    return { cloudinary: { public_id: cloudinary_response["public_id"] } } unless cloudinary_response.empty?
    nil
  end

  def image_cache_key
    "#{cloudinary_response['public_id']}-#{updated_at}"
  end

  def has_image?
    !cloudinary_response.empty?
  end

  def generate_image(force = false)
    image_maker_url = ENV["CONSTITUENCY_IMAGE_MAKER_URL"]
    if !cloudinary_response.empty? && !force
      Rails.logger.debug "Seems like there is an image already"
    else
      Rails.logger.debug "Force flag is #{force}"
      begin
        raise "CONSTITUENCY_IMAGE_MAKER_URL env not set" if image_maker_url.blank?
        url = "#{image_maker_url}/snapshot?url=#{constituency_map_url(constituency_id: slug)}&width=1200&height=600"
        puts "Image url is #{url}"
        response = HTTParty.get(url)
        if response.code != 200
          Rails.logger.error "Image could not be saved, got wrong response code"
          reload
          false
        else
          Cloudinary::Api.delete_resources([cloudinary_response['public_id']]) if has_image?
          image_name = "constituency-#{slug}-#{SecureRandom.hex(4)}"
          base64 = Base64.encode64(response.body.to_s)
          dat = "data:image/png;base64,#{base64}"
          self.cloudinary_response = Cloudinary::Uploader.upload(dat, public_id: image_name)
          save
          true
        end
      rescue Error, Exception => e
        Rails.logger.error "Caught error generating image for constituency with id #{id} - #{e.message}"
        reload
        false
      end
    end
  end

  def generate_map_meta
    return if map.blank?
    results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Centroid(shape)) as wkt from maps where id='#{map.id}'"
    return if results.empty?
    bounding_box_results = ActiveRecord::Base.connection.exec_query "select id, ST_AsText(ST_Envelope(shape)) as wkt from maps where id='#{map.id}'"
    return if bounding_box_results.empty?
    bounding_polygon = RGeo::Cartesian.preferred_factory.parse_wkt(bounding_box_results.first['wkt'])

    center_data = RGeo::Cartesian.preferred_factory.parse_wkt(results.first['wkt'])
    self.center = {
      lon: center_data.x,
      lat: center_data.y
    }
    self.bounding_coords = bounding_polygon.coordinates[0]
    self.geojson = map.to_simplified_geojson(0.00001)
    save
  end

  def influencers
    if is_assembly?
      User.unscoped.where(constituency_id: id)
    else
      User.unscoped.where(constituency_id: Constituency.find(id).children.map(&:id))
    end
  end
end
