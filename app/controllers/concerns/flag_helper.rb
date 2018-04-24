module FlagHelper
  extend ActiveSupport::Concern

  included do
    helper_method :flag
  end

  def flag_resource
    flag = @flaggable.flags.where(user_id: current_user_id).first
    render json: { error: "already_flagged" } unless flag.nil?
    return unless flag.nil?

    if @flaggable.flag(@reason_to_flag, current_user_id)
      render json: {
        data: {
          message: "flagged"
        },
        status_code: 1
      }
    else
      render json: {
        error: "internal_server_error",
        message: @flaggable.errors.messages,
        status: 500
      }
    end
  end
end
