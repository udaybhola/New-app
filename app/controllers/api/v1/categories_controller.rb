module Api
  module V1
    class CategoriesController < ApiV1Controller
      def index
        @categories = Category.all
      end
    end
  end
end
