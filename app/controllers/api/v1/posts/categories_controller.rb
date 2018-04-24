module Api
  module V1
    module Posts
      class CategoriesController < Api::V1::ApiV1Controller
        before_action :validate_params

        def count
          @categories = ApiResponseModels::Api::V1::Posts::CategoriesCount.fetch_data(@constituency_id)
        end

        def validate_params
          @constituency_id = params.permit(:constituency_id)["constituency_id"]
        end
      end
    end
  end
end
