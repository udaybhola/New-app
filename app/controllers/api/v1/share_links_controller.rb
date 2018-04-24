module Api
  module V1
    class ShareLinksController < ApiV1Controller
      before_action :validate_request

      def post
        @post = Post.find(@id)
        raise Error::CustomError(nil, nil, "id param cannot be empty") if @post.nil?

        @title = @post.name
        @description = @post.share_description
        @image_url = @post.image_url
        @url, @short_url = @post.generate_share_link

        render 'link'
      end

      def constituency; end

      def candidature
        @candidature = Candidature.find(@id)
        raise Error::CustomError(nil, nil, "Could not find a candidature with the given id") if @candidature.nil?

        @title = @candidature.share_name
        @description = @candidature.share_description
        @image_url = @candidature.share_image_url
        @url, @short_url = @candidature.generate_share_link

        render 'link'
      end

      def influencer
        @influencer = User.find(@id)
        raise Error::CustomError(nil, nil, "Could not find a influencer with the given id") if @influencer.nil?

        @title = @influencer.share_name
        @description = @influencer.share_description
        @image_url = @influencer.share_image_url
        @url, @short_url = @influencer.generate_share_link

        render 'link'
      end

      def country_state; end

      private

      def generate_firebase_dynamic_link
        firebase_dynamic_link = Firebase::DynamicLink.new(
          title: @title,
          description: @description,
          image_url: @image_url,
          link: @url
        )
        @short_url, response = firebase_dynamic_link.generate
        response
      end

      private

      def validate_request
        @params = params.permit(:id)
        @id = @params["id"]
        raise Error::CustomError.new(nil, nil, "id param cannot be empty") if @id.blank?
      end
    end
  end
end
