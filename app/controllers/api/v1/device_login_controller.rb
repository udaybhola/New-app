module Api
  module V1
    class DeviceLoginController < ApiV1Controller
      before_action :permitted_params, only: [:login]
      skip_before_action :authenticate_api_v1_user!, only: [:login]

      def login
        firebase_user = FirebaseUser.find_by(uid: @uid)
        if firebase_user.nil?
          firebase_user = FirebaseUser.new
          firebase_user.uid = @uid
        end
        user, client_id, token, expiry = firebase_user.login(@token, @uid)
        sign_in(:user, user, store: false, bypass: false)

        render json: {
          :data =>  {
            :'access-token' => token,
            :client => client_id,
            :expiry => expiry,
            :uid => user.uid,
            :'token-type' => 'Bearer'
          },
          :status_code => 1
        }
      end

      def logout
        @user.tokens = {}
        unless @user.save!
          render json: {
            :data => {
              message: "Logged out user"
            }
          }
        end
      end

      private

      def permitted_params
        @token = params.permit(:jwt_token)[:jwt_token]
        @uid = params.permit(:uid)[:uid]
        raise "Param needed for login not found error" if @token.nil?
      end
    end
  end
end
