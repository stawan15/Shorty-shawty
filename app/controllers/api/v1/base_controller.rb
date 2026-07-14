module Api
  module V1
    class BaseController < ApplicationController
      skip_before_action :verify_authenticity_token
      before_action :authenticate_api_user!

      private

      def authenticate_api_user!
        token = request.headers["Authorization"]&.split(" ")&.last
        @current_api_user = User.find_by(api_token: token) if token.present?
        render json: { error: "Unauthorized. Pass your API token as: Authorization: Bearer <token>" },
               status: :unauthorized unless @current_api_user
      end
    end
  end
end
