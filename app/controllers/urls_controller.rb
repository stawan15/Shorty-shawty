class UrlsController < ApplicationController
  before_action :authenticate_user!, only: [:destroy, :analytics]
  before_action :set_url, only: [:destroy, :analytics, :qr_code]

  def index
    @url = Url.new
    @urls = user_signed_in? ? current_user.urls.order(created_at: :desc) : []
  end

  def create
    @url = Url.new(permitted_url_params)
    @url.user = current_user if user_signed_in?

    if @url.save
      if user_signed_in?
        redirect_to root_path, notice: "Short URL created successfully!"
      else
        redirect_to root_path, flash: {
          guest_short_url: short_url_for(@url),
          guest_original_url: @url.original_url
        }
      end
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
      module_size: 7,
      standalone: true
    )

    if params[:format] == "svg"
      render plain: svg, content_type: "image/svg+xml"
    else
      # Embed as data URL — works on all devices, no second HTTP request
      @qr_data_url = "data:image/svg+xml;base64,#{Base64.strict_encode64(svg)}"
      @qr_svg_download = svg
    end
  end

  private

  def set_url
    if action_name.in?(%w[destroy analytics]) && user_signed_in?
      @url = current_user.urls.find(params[:id])
    else
      @url = Url.find(params[:id])
    end
  end

  def permitted_url_params
    allowed = [:original_url]
    allowed << :short_code if user_signed_in?
    params.require(:url).permit(*allowed)
  end
end
