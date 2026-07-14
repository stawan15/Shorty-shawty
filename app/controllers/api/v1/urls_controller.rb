module Api
  module V1
    class UrlsController < BaseController
      before_action :set_url, only: [:show, :destroy]

      def index
        urls = @current_api_user.urls.order(created_at: :desc)
        render json: urls.as_json(only: [:id, :original_url, :short_code, :clicks, :created_at],
                                  methods: [])
      end

      def show
        render json: @url.as_json(
          only: [:id, :original_url, :short_code, :clicks, :created_at],
          include: { click_events: { only: [:referrer, :ip_address, :created_at] } }
        )
      end

      def create
        url = @current_api_user.urls.build(url_params)
        if url.save
          render json: url.as_json(only: [:id, :original_url, :short_code, :clicks, :created_at]),
                 status: :created
        else
          render json: { errors: url.errors.full_messages }, status: :unprocessable_entity
        end
      end

      def destroy
        @url.destroy
        head :no_content
      end

      private

      def set_url
        @url = @current_api_user.urls.find(params[:id])
      rescue ActiveRecord::RecordNotFound
        render json: { error: "URL not found" }, status: :not_found
      end

      def url_params
        params.require(:url).permit(:original_url, :short_code)
      end
    end
  end
end
