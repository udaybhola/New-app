require_relative './custom_error.rb'

module Error
  module ErrorHandler
    def self.included(clazz)
      clazz.class_eval do
        rescue_from StandardError do |e|
          Rails.logger.fatal e.backtrace.to_s
          respond(:internal_server_error, 500, e.to_s)
        end

        rescue_from CustomError do |e|
          Rails.logger.fatal e.backtrace.to_s
          respond(e.error, e.status, e.message)
        end

        rescue_from ActiveRecord::RecordNotFound do |e|
          Rails.logger.fatal e.backtrace.to_s
          respond(:record_not_found, 404, e.to_s)
        end
      end

      private

      def respond(error, status, message)
        json = {
          status: status,
          error: error,
          message: message
        }.as_json
        render json: json
      end
    end
  end
end
