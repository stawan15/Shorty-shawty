module Api
  module V1
    class UsersController < BaseController
      def show
        render json: {
          id: @current_api_user.id,
          email: @current_api_user.email,
          api_token: @current_api_user.api_token,
          urls_count: @current_api_user.urls.count,
          created_at: @current_api_user.created_at
        }
      end
    end
  end
end
