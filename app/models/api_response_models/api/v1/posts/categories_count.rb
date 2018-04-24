module ApiResponseModels
  module Api
    module V1
      module Posts
        class CategoriesCount
          include ActiveModel::Model
          attr_accessor :id, :name, :count, :image, :slug

          def initialize(id, name, count, image, slug)
            @id = id
            @name = name
            @count = count
            @image = image
            @slug = slug
          end

          def self.fetch_from_stub
            categories = []
            json_string = File.read("#{Rails.root}/app/models/api_response_models/api/v1/posts/categories_count.json")
            categories_with_count = JSON.parse(json_string, object_class: ApiResponseModels::CustomOstruct)
            categories_with_count.each do |item|
              categories << new(item["id"], item["name"], item["count"], item["image"], item["slug"])
            end
            categories
          end

          def self.fetch_from_active_record(constituency_id)
            categories = []
            constituency = Constituency.find(constituency_id)
            all_categories_with_post_counts = Post.joins(:category).where(region_id: [constituency_id, constituency.parent.id]).group("posts.category_id", "categories.name", "categories.slug", "categories.image").select("posts.category_id").count
            all_categories = Category.all
            # output will be like {["700119fa-c4f1-4c41-82a2-e592510a7070", "Environmental Issue", "environmental-issue", "image/upload/v1513348803/sekqrx54zlecraxryxgq.png"]=>2}
            category_hash = {}
            all_categories_with_post_counts.each do |category_array, count|
              name = category_array[1]
              category_hash[name] = { count: count }
            end
            all_categories.each do |category|
              count = category_hash[category.name] ? category_hash[category.name][:count] : 0
              categories << new(category.id, category.name, count, category.image, category.slug)
            end
            categories = categories.sort_by(&:name)
            categories
          end

          def self.fetch_data(constituency_id)
            fetch_from_active_record(constituency_id)
          end
        end
      end
    end
  end
end
