module Api
  module V1
    class ApiV1Controller < ApplicationController
      GET_REQUESTS_WHICH_NEED_TOKEN = [
        { "controller" => "api/v1/influencers",
          "action" => "scorelog" },
        { "controller" => "api/v1/influencers",
          "action" => "issues" },
        { "controller" => "api/v1/posts",
          "action" => "mine" },
        { "controller" => "api/v1/home",
          "action" => "cloudinary_config" },
        { "controller" => "api/v1/candidatures", "action" => "current_voted_candidate"}
      ].freeze
      POST_REQUESTS_WHICH_DONT_NEED_TOKEN = [
        { "controller" => "api/v1/country_states",
          "action" => "parties_stats" },
        { "controller" => "api/v1/constituencies",
          "action" => "parties_stats" },
        { "controller" => "api/v1/candidate_nominations",
          "action" => "create" }
      ].freeze

      include DeviseTokenAuth::Concerns::SetUserByToken
      include Error::ErrorHandler
      before_action :authenticate_api_v1_user!, unless: :auth_not_required?
      protect_from_forgery with: :null_session
      before_action :assign_user
      before_action :check_non_archived_user

      def assign_user
        @user = current_api_v1_user
      end

      def current_user_id
        @user.nil? ? nil : @user.id
      end

      def auth_not_required?
        (request.method == "GET" && !get_request_which_need_token(request.filtered_parameters)) || (request.method == "POST" && post_request_which_dont_need_token(request.filtered_parameters))
      end

      def get_request_which_need_token(filtered_params)
        GET_REQUESTS_WHICH_NEED_TOKEN.each do |item|
          return true if item["controller"] == filtered_params["controller"] && item["action"] == filtered_params["action"]
        end
        false
      end

      def post_request_which_dont_need_token(filtered_params)
        POST_REQUESTS_WHICH_DONT_NEED_TOKEN.each do |item|
          return true if item["controller"] == filtered_params["controller"] && item["action"] == filtered_params["action"]
        end
        false
      end

      def check_non_archived_user
        if @user && request.method == "POST"
          raise "Not Allowed" if @user.archived
        end
      end
    end
  end
end
