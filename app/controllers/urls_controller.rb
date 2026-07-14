class UrlsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy, :analytics]
  before_action :set_url, only: [:destroy, :analytics, :qr_code]

  def index
    @url = Url.new
    @urls = user_signed_in? ? current_user.urls.order(created_at: :desc) : []
  end

  def create
    @url = Url.new(url_params)
    @url.user = current_user if user_signed_in?

    if @url.save
      redirect_to root_path, notice: "Short URL created successfully!"
    else
      @urls = user_signed_in? ? current_user.urls.order(created_at: :desc) : []
      render :index, status: :unprocessable_entity
    end
  end

  def destroy
    @url.destroy
    redirect_to root_path, notice: "URL deleted."
  end

  def analytics
    @clicks_by_day = @url.click_events
                         .group("DATE(created_at)")
                         .order("DATE(created_at) DESC")
                         .count
    @recent_clicks = @url.click_events.order(created_at: :desc).limit(50)
  end

  def qr_code
    qr = RQRCode::QRCode.new(short_url_for(@url))
    svg = qr.as_svg(
      offset: 0,
      color: "000",
      shape_rendering: "crispEdges",
      module_size: 6,
      standalone: true
    )
    render plain: svg, content_type: "image/svg+xml"
  end

  private

  def set_url
    if action_name.in?(%w[destroy analytics]) && user_signed_in?
      @url = current_user.urls.find(params[:id])
    else
      @url = Url.find(params[:id])
    end
  end

  def url_params
    params.require(:url).permit(:original_url, :short_code)
  end
end
